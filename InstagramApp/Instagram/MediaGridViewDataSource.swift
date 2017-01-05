//
//  MediaGridViewDataSource.swift
//  Instagram
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import UIKit
import InstagramData
import SDWebImage

extension MediaGridView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return InstagramData.shared.feedManager.mediaCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        print("Loading cell \(indexPath.row)")
        let cell: MediaGridViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaGridView.reuseIdentifier,
                                                                         for: indexPath) as! MediaGridViewCell
        cell.backgroundColor = .red
        cell.currentItem = item(at: indexPath.row)
        cell.username.text = cell.currentItem?.username
        setImage(for: cell, at: indexPath)
        setProfilePictureImage(for: cell, at: indexPath)
        return cell
    }
}

extension MediaGridView: FeedManagerPrefetchingDelegate {
    
    func feedManager(_ feedManager: FeedManager, prefetchDataFor mediaItems: [MediaItem]) {
//        if let firstItem = mediaItems.first?.id, let lastItem = mediaItems.last?.id {
//            let firstIndex = InstagramData.shared.feedManager.mediaIDs.index(of: firstItem)!
//            let lastIndex = InstagramData.shared.feedManager.mediaIDs.index(of: lastItem)!
//            print("Prefetching images from \(firstIndex) to \(lastIndex)")
//        }
        let urls = mediaItems.map({ $0.thumbnail })
        SDWebImagePrefetcher.shared().prefetchURLs(urls)
    }
    
    func feedManager(_ feedManager: FeedManager, removeCachedDataFor mediaItems: [MediaItem]) {
//        if let firstItem = mediaItems.first?.id, let lastItem = mediaItems.last?.id {
//            let firstIndex = InstagramData.shared.feedManager.mediaIDs.index(of: firstItem)!
//            let lastIndex = InstagramData.shared.feedManager.mediaIDs.index(of: lastItem)!
//            print("Removing cache from \(firstIndex) to \(lastIndex)")
//        }
        for media in mediaItems {
            let cacheKey = SDWebImageManager.shared().cacheKey(for: media.thumbnail)
            SDWebImageManager.shared().imageCache.removeImage(forKey: cacheKey, fromDisk: false)
        }
    }
    
}

class MediaGridViewCellOperationDelegate: MediaGridViewCellDelegate {
    var operation: SDWebImageOperation?
    
    func mediaGridViewCellWillPrepareForReuse(_ mediaGridViewCell: MediaGridViewCell) {
        operation?.cancel()
        operation = nil
    }
}

extension MediaGridView {
    
    func index(of item: MediaGridViewItem) -> Int? {
        return InstagramData.shared.feedManager.mediaIDs.index(of: item.id)
    }
    
    func item(at index: Int) -> MediaGridViewItem {
        let mediaID = InstagramData.shared.feedManager.mediaIDs[index]
        
        let sema = DispatchSemaphore(value: 0)
        var mediaItem: MediaItem!
        InstagramData.shared.feedManager.mediaItem(for: mediaID) { (result) in
            mediaItem = result
            sema.signal()
        }
        sema.wait()
        return MediaGridViewItem(id: mediaItem.id,
                                 url: mediaItem.thumbnail,
                                 profilePicture: mediaItem.owner.profilePictureURL,
                                 username:mediaItem.owner.username)
    }
    
    func items(for indexPaths: [IndexPath]) -> [MediaGridViewItem] {
        var result: [MediaGridViewItem] = []
        for indexPath in indexPaths {
            result.append(item(at: indexPath.row))
        }
        return result
    }
    
    func setImage(for cell: MediaGridViewCell, at indexPath: IndexPath) {
        let item = cell.currentItem!
        let image = SDImageCache.shared().imageFromMemoryCache(forKey: item.url.absoluteString)
        if let image = image {
            cell.imageView.image = image
            return
        }
        
        let cellDelegate = MediaGridViewCellOperationDelegate()
        
        cellDelegate.operation = SDWebImageManager.shared().downloadImage(with: item.url, options: [], progress: nil)
        { [cellDelegate] (image, error, cacheType, finished, url) in
            if image != nil {
                self.reloadCell(for: item)
            }
            cellDelegate.operation = nil
        }
        cell.delegate = cellDelegate
    }
    
    func setProfilePictureImage(for cell: MediaGridViewCell, at indexPath: IndexPath) {
        let item = cell.currentItem!
        let image = SDImageCache.shared().imageFromMemoryCache(forKey: item.profilePicture.absoluteString)
        if let image = image {
            cell.profilePicture.image = image
            return
        }
        
        let cellDelegate = MediaGridViewCellOperationDelegate()
        
        cellDelegate.operation = SDWebImageManager.shared().downloadImage(with: item.profilePicture, options: [], progress: nil)
        { [cellDelegate] (image, error, cacheType, finished, url) in
            if image != nil {
                self.reloadCell(for: item)
            }
            cellDelegate.operation = nil
        }
        cell.delegate = cellDelegate
    }
}
