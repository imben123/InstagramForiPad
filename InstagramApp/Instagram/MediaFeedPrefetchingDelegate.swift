//
//  MediaFeedPrefetchingDelegate.swift
//  Instagram
//
//  Created by Ben Davis on 16/04/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import InstagramData
import SDWebImage

class MediaGridViewPrefetchingDelegate: MediaFeedPrefetchingDelegate {
    
    let mediaGridView: MediaGridView
    let dataSource: MediaFeedGridViewDataSource
    
    init(mediaGridView: MediaGridView, dataSource: MediaFeedGridViewDataSource) {
        self.mediaGridView = mediaGridView
        self.dataSource = dataSource
    }
    
    func mediaFeed(_ mediaFeed: MediaFeed, prefetchDataFor mediaItems: [MediaItem]) {
        let urls = mediaItems.map({ $0.thumbnail })
        SDWebImagePrefetcher.shared.prefetchURLs(urls)
    }
    
    func mediaFeed(_ mediaFeed: MediaFeed, removeCachedDataFor mediaItems: [MediaItem]) {
        for media in mediaItems {
            let cacheKey = SDWebImageManager.shared.cacheKey(for: media.thumbnail)
            SDWebImageManager.shared.imageCache.removeImage(forKey: cacheKey, cacheType: .memory)
        }
    }
    
    func mediaFeed(_ mediaFeed: MediaFeed, updatedMediaItems mediaItems: [MediaItem]) {
        
        var indexPaths: [IndexPath] = []
        for mediaItem in mediaItems {
            if let index = dataSource.indexOfItem(with: mediaItem.id) {
                indexPaths.append(IndexPath(item: index, section: 0))
            }
        }
        mediaGridView.reloadItems(at: indexPaths)
    }
}
