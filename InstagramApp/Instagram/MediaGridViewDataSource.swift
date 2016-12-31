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
        return InstagramData.shared.feedManager.media.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MediaGridViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaGridView.reuseIdentifier,
                                                                         for: indexPath) as! MediaGridViewCell
        cell.backgroundColor = .red
        cell.currentItem = item(at: indexPath.row)
        cell.imageView.image = image(for: item(at: indexPath.row))
        return cell
    }
}

extension MediaGridView: UICollectionViewDataSourcePrefetching {
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = items(for: indexPaths).map() { $0.url }
        SDWebImagePrefetcher.shared().prefetchURLs(urls)
    }
}

extension MediaGridView {
    
    func index(of item: MediaGridViewItem) -> Int? {
        var result = 0
        for mediaItem in InstagramData.shared.feedManager.media {
            if mediaItem.thumbnail == item.url {
                return result
            }
            result += 1
        }
        return nil
    }
    
    func item(at index: Int) -> MediaGridViewItem {
        let media = InstagramData.shared.feedManager.media[index]
        return MediaGridViewItem(url: media.thumbnail!)
    }
    
    func items(for indexPaths: [IndexPath]) -> [MediaGridViewItem] {
        var result: [MediaGridViewItem] = []
        for indexPath in indexPaths {
            result.append(item(at: indexPath.row))
        }
        return result
    }
    
    func image(for item: MediaGridViewItem) -> UIImage? {
        let image = SDImageCache.shared().imageFromMemoryCache(forKey: item.url.absoluteString)
        if let image = image {
            return image
        }
        
        SDWebImageManager.shared().downloadImage(with: item.url, options: [], progress: { (receivedSize, expectedSize) in
            // Nothing
        }, completed: { (image, error, cacheType, finished, url) in
            self.reloadCell(for: item)
        })
        
        return nil
    }
}
