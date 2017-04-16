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

protocol MediaFeedDataSourceUserActionDelegate: class {
    func mediaFeedDataSource(_ sender: MediaFeedDataSource, userPressOwnerOfMediaItem mediaItem: MediaItem)
}

protocol MediaFeedDataSourceObserver: class {
    func mediaFeedDataSource(_ sender: MediaFeedDataSource, mediaFeedUpdated itemCount: Int)
}

class MediaFeedDataSource: NSObject {
    
    let mediaGridView: MediaGridView
    let mediaFeed: MediaFeed

    weak var userActionDelegate: MediaFeedDataSourceUserActionDelegate?
    weak var observer: MediaFeedDataSourceObserver?
    
    // TODO: move this logic to managers
    var fetchingMoreMedia = false
    
    init(mediaFeed: MediaFeed, mediaGridView: MediaGridView) {
        self.mediaGridView = mediaGridView
        self.mediaFeed = mediaFeed
        super.init()
        mediaFeed.prefetchingDelegate = self
        mediaGridView.dataSource = self
    }
    
    func updateLatestMedia() {
        fetchLatestMedia()
        refreshMostRecentPosts()
    }
    
    private func fetchLatestMedia() {
        
        mediaFeed.fetchNewestMedia({ [weak self] in
            
            guard let strongself = self,
                let newMediaCount = self?.mediaFeed.mediaCount else {
                    return
            }
            
            strongself.observer?.mediaFeedDataSource(strongself, mediaFeedUpdated: newMediaCount)
            strongself.mediaGridView.reloadData()
            
        })
    }
    
    private func refreshMostRecentPosts() {
        
        let numberOfPosts = mediaFeed.mediaIDs.count
        
        // Update 20 most recent
        for index in 0..<min(20, numberOfPosts) {
            let mediaItem = self.mediaItem(at: index)
            InstagramData.shared.mediaManager.updateMediaItem(mediaItem)
        }
    }
    
    func loadMoreMedia() {
        
        guard fetchingMoreMedia == false else {
            return
        }
        
        fetchingMoreMedia = true
        mediaFeed.fetchMoreMedia({ [weak self] in
            self?.mediaGridView.reloadData()
            self?.fetchingMoreMedia = false
            }, failure: { [weak self] in
                self?.fetchingMoreMedia = false
        })
    }
    
    func reloadCell(for item: MediaGridViewItem) {
        guard let index = index(of: item) else {
            return
        }
        let indexPath = IndexPath(item: index, section: 0)
        mediaGridView.reloadItems(at: [indexPath])
    }
}

extension MediaFeedDataSource: MediaGridViewDataSource {
    
    func mediaGridViewNeedsMoreMedia(_ sender: MediaGridView) {
        loadMoreMedia()
    }
    
    func mediaGridViewNeedsUpdateVisibleCells(_ sender: MediaGridView) {
        
        let visibleIndexPaths = mediaGridView.indexPathsForVisibleItems
        
        let urls = visibleIndexPaths.map { indexPath -> URL in
            mediaItem(at: indexPath.item).display
        }
        SDWebImagePrefetcher.shared().prefetchURLs(urls)
        
        // Make cell image high priority if the image doesn't already exist
        for indexPath in visibleIndexPaths {
            if let cell = sender.cellForItem(at: indexPath) as? MediaGridViewCell, cell.imageView.image == nil {
                setImage(for: cell, at: indexPath, highPriority: true)
            }
        }
    }
    
    func mediaGridView(_ sender: MediaGridView, mediaItemAt index: Int) -> MediaItem {
        return mediaItem(at: index)
    }
    
    func mediaGridView(_ sender: MediaGridView, indexOfItemWith id: String) -> Int? {
        return indexOfItem(with: id)
    }
}

extension MediaFeedDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaFeed.mediaCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MediaGridViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaGridView.reuseIdentifier,
                                                                         for: indexPath) as! MediaGridViewCell
        cell.currentItem = item(at: indexPath.row)
        cell.liked = cell.currentItem!.viewerHasLiked
        cell.username.text = cell.currentItem?.username
        setImage(for: cell, at: indexPath)
        setProfilePictureImage(for: cell, at: indexPath)
        cell.userActionDelegate = self
        return cell
    }
    
    // Used the hold the download operation and cancel it if the cell is reused
    class MediaGridViewCellOperationDelegate: MediaGridViewCellDelegate {
        var imageDownloadOperation: SDWebImageOperation?
        var profilePictureDownloadOperation: SDWebImageOperation?
        
        func mediaGridViewCellWillPrepareForReuse(_ mediaGridViewCell: MediaGridViewCell) {
            
            // Performance is better when these are not cancelled.
            //
            // TODO: Come up with a better system that only cancels oldest image downloads
            //       when there are > 100(?) downloads in progress.
            //
            //       Perhaps an SDWebImage extension to auto-cancel from group of downloads
            //       when a given limit is exceeded.
            
//            imageDownloadOperation?.cancel()
//            profilePictureDownloadOperation?.cancel()
            
            imageDownloadOperation = nil
            profilePictureDownloadOperation = nil
            
        }
    }
    
    fileprivate func setImage(for cell: MediaGridViewCell, at indexPath: IndexPath, highPriority: Bool = false) {
        let item = cell.currentItem!
        let image = SDImageCache.shared().imageFromMemoryCache(forKey: item.url.absoluteString)
        if let image = image {
            cell.imageView.image = image
            return
        }
        
        let cellDelegate = cellOperationsDelegate(for: cell)
        
        let options = highPriority ? SDWebImageOptions.highPriority : []
        cellDelegate.imageDownloadOperation = SDWebImageManager.shared().downloadImage(with: item.url,
                                                                                       options: options,
                                                                                       progress: nil)
        { [cellDelegate, weak self] (image, error, cacheType, finished, url) in
            if image != nil {
                self?.reloadCell(for: item)
            }
            cellDelegate.imageDownloadOperation = nil
        }
    }
    
    private func setProfilePictureImage(for cell: MediaGridViewCell, at indexPath: IndexPath) {
        let item = cell.currentItem!
        let image = SDImageCache.shared().imageFromMemoryCache(forKey: item.profilePicture.absoluteString)
        if let image = image {
            cell.profilePicture.image = image
            return
        }
        
        let cellDelegate = cellOperationsDelegate(for: cell)
        
        cellDelegate.profilePictureDownloadOperation = SDWebImageManager.shared().downloadImage(with: item.profilePicture,
                                                                                                options: [],
                                                                                                progress: nil)
        { [cellDelegate, weak self] (image, error, cacheType, finished, url) in
            if image != nil {
                self?.reloadCell(for: item)
            }
            cellDelegate.profilePictureDownloadOperation = nil
        }
    }
    
    private func cellOperationsDelegate(for cell: MediaGridViewCell) -> MediaGridViewCellOperationDelegate {
        if let result = cell.delegate as? MediaGridViewCellOperationDelegate {
            return result
        }
        let result = MediaGridViewCellOperationDelegate()
        cell.delegate = result
        return result
    }
}

extension MediaFeedDataSource: MediaFeedPrefetchingDelegate {
    
    func mediaFeed(_ mediaFeed: MediaFeed, prefetchDataFor mediaItems: [MediaItem]) {
        let urls = mediaItems.map({ $0.thumbnail })
        SDWebImagePrefetcher.shared().prefetchURLs(urls)
    }
    
    func mediaFeed(_ mediaFeed: MediaFeed, removeCachedDataFor mediaItems: [MediaItem]) {
        for media in mediaItems {
            let cacheKey = SDWebImageManager.shared().cacheKey(for: media.thumbnail)
            SDWebImageManager.shared().imageCache.removeImage(forKey: cacheKey, fromDisk: false)
        }
    }
    
    func mediaFeed(_ mediaFeed: MediaFeed, updatedMediaItems mediaItems: [MediaItem]) {
        
        var indexPaths: [IndexPath] = []
        for mediaItem in mediaItems {
            if let index = indexOfItem(with: mediaItem.id) {
                indexPaths.append(IndexPath(item: index, section: 0))
            }
        }
        mediaGridView.reloadItems(at: indexPaths)
    }
}

extension MediaFeedDataSource: MediaGridViewCellUserActionDelegate {
    
    func mediaGridViewCellLikePressed(_ mediaGridViewCell: MediaGridViewCell) {
        let mediaId = mediaGridViewCell.currentItem!.id
        InstagramData.shared.likeReqestsManager.likePost(with: mediaId)
        updateMediaItemInMemCache(for: mediaId, liked: true)
    }
    
    func mediaGridViewCellUnlikePressed(_ mediaGridViewCell: MediaGridViewCell) {
        let mediaId = mediaGridViewCell.currentItem!.id
        InstagramData.shared.likeReqestsManager.unlikePost(with: mediaGridViewCell.currentItem!.id)
        updateMediaItemInMemCache(for: mediaId, liked: false)
    }
    
    func updateMediaItemInMemCache(for mediaId: String, liked: Bool) {
        mediaFeed.mediaItem(for: mediaId) { (mediaItem) in
            if let mediaItem = mediaItem {
                var mediaItem = mediaItem
                mediaItem.viewerHasLiked = liked
                self.mediaFeed.updateMediaItemInMemCache(with: mediaItem)
            }
        }
    }
    
    func mediaGridViewCellOwnerPressed(_ mediaGridViewCell: MediaGridViewCell) {
        let mediaId = mediaGridViewCell.currentItem!.id
        let mediaItem = self.mediaItem(at: indexOfItem(with: mediaId)!)
        userActionDelegate?.mediaFeedDataSource(self, userPressOwnerOfMediaItem: mediaItem)
    }
}

// Helpers
extension MediaFeedDataSource {
    
    fileprivate func mediaItem(at index: Int) -> MediaItem {
        let mediaID = mediaFeed.mediaIDs[index]
        
        var mediaItem: MediaItem!
        let sema = DispatchSemaphore(value: 0)
        mediaFeed.mediaItem(for: mediaID) { (result) in
            mediaItem = result
            sema.signal()
        }
        sema.wait()
        return mediaItem
    }
    
    fileprivate func index(of item: MediaGridViewItem) -> Int? {
        return indexOfItem(with: item.id)
    }
    
    fileprivate func indexOfItem(with id: String) -> Int? {
        return mediaFeed.mediaIDs.index(of: id)
    }
    
    fileprivate func item(at index: Int) -> MediaGridViewItem {
        let mediaItem = self.mediaItem(at: index)
        return MediaGridViewItem(id: mediaItem.id,
                                 url: mediaItem.thumbnail,
                                 profilePicture: mediaItem.owner.profilePictureURL,
                                 username: mediaItem.owner.username,
                                 code: mediaItem.code,
                                 viewerHasLiked: mediaItem.viewerHasLiked)
    }
    
    fileprivate func items(for indexPaths: [IndexPath]) -> [MediaGridViewItem] {
        var result: [MediaGridViewItem] = []
        for indexPath in indexPaths {
            result.append(item(at: indexPath.row))
        }
        return result
    }
}
