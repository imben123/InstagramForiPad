//
//  InstagramFeed.swift
//  InstagramData
//
//  Created by Ben Davis on 11/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import Foundation

public protocol MediaFeedPrefetchingDelegate: class {
    func mediaFeed(_ mediaFeed: MediaFeed, prefetchDataFor mediaItems: [MediaItem])
    func mediaFeed(_ mediaFeed: MediaFeed, removeCachedDataFor mediaItems: [MediaItem])
    func mediaFeed(_ mediaFeed: MediaFeed, updatedMediaItems mediaItems: [MediaItem])
}

public class MediaFeed {
    
    public weak var prefetchingDelegate: MediaFeedPrefetchingDelegate?

    fileprivate let mediaList: ScrollingMediaList
    private let feedWebStore: MediaListWebStore
    
    public var mediaIDs: [String] {
        return mediaList.itemIDsBeforeFirstGap
    }
    
    public var mediaCount: Int {
        return mediaList.mediaCount
    }
    
    private var endCursor: String? {
        return mediaList.firstGapCursor
    }
    
    init(mediaList: ScrollingMediaList, feedWebStore: MediaListWebStore) {
        self.feedWebStore = feedWebStore
        self.mediaList = mediaList
        self.mediaList.prefetchingDelegate = self
    }
    
    public func fetchNewestMedia(_ completion: (()->())?, failure: (()->())? = nil) {
        
        feedWebStore.fetchNewestMedia({ (newMedia, newEndCursor) in
            
            self.mediaList.addNewMedia(newMedia, with: newEndCursor)
            completion?()
            
        }, failure: failure)
    }
    
    public func fetchMoreMedia(_ completion: (()->())?, failure: (()->())? = nil) {
        guard let currentEndCursor = self.endCursor else {
            fetchNewestMedia(completion, failure: failure)
            return
        }
        
        feedWebStore.fetchMedia(after: currentEndCursor, completion: { (newMedia, newEndCursor) in
            
            self.mediaList.appendMoreMedia(newMedia, from: currentEndCursor, to: newEndCursor)
            completion?()
            
        }, failure: failure)
    }
    
    public func mediaItem(for id: String, completion: @escaping (MediaItem?)->Void) {
        mediaList.mediaItem(for: id, completion: completion)
    }
    
    public func updateMediaItemInMemCache(with mediaItem: MediaItem) {
        mediaList.updateMediaItemInMemCache(with: mediaItem)
    }
}

extension MediaFeed: ScrollingMediaListPrefetchingDelegate {
    
    func scrollingMediaList(_ scrollingMediaList: ScrollingMediaList, prefetchDataFor mediaItems: [MediaItem]) {
        prefetchingDelegate?.mediaFeed(self, prefetchDataFor: mediaItems)
    }
    
    func scrollingMediaList(_ scrollingMediaList: ScrollingMediaList, removeCachedDataFor mediaItems: [MediaItem]) {
        prefetchingDelegate?.mediaFeed(self, removeCachedDataFor: mediaItems)
    }
}

extension MediaFeed: MediaDataStoreObserver {
    
    func mediaDataStore(_ sender: MediaDataStore, didArchiveNewMedia newMedia: [MediaItem]) {
        var result: [MediaItem] = []
        for newMediaItem in newMedia {
            if let oldMediaItem = mediaList.mediaItemFromCache(for: newMediaItem.id) {
                if newMediaItem != oldMediaItem {
                    updateMediaItemInMemCache(with: newMediaItem)
                    result.append(newMediaItem)
                }
            }
        }
        if result.count > 0 {
            prefetchingDelegate?.mediaFeed(self, updatedMediaItems: result)
        }
    }
}
