//
//  FeedManager.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol FeedManagerPrefetchingDelegate: class {
    func feedManager(_ feedManager: FeedManager, prefetchDataFor mediaItems: [MediaItem])
    func feedManager(_ feedManager: FeedManager, removeCachedDataFor mediaItems: [MediaItem])
    func feedManager(_ feedManager: FeedManager, updatedMediaItems mediaItems: [MediaItem])
}

public class FeedManager {
    
    public weak var prefetchingDelegate: FeedManagerPrefetchingDelegate?
    
    private let feedWebStore: FeedWebStore
    private let mediaDataStore: MediaDataStore
    private let mediaList: ScrollingMediaList
    private var endCursor: String? {
        return mediaList.firstGapCursor
    }
    
    convenience init(communicator: APICommunicator, mediaDataStore: MediaDataStore) {
        let mediaList = ScrollingMediaList(name: "feed",
                                           pageSize: 50,
                                           mediaDataStore: mediaDataStore,
                                           listDataStore: GappedListDataStore())
        
        let feedWebStore = FeedWebStore(communicator: communicator)
        
        self.init(feedWebStore: feedWebStore,
                  mediaList: mediaList,
                  mediaDataStore: mediaDataStore)
    }
    
    init(feedWebStore: FeedWebStore,
         mediaList: ScrollingMediaList,
         mediaDataStore: MediaDataStore) {
        
        self.mediaDataStore = mediaDataStore
        self.mediaList = mediaList
        self.feedWebStore = feedWebStore
        self.mediaList.prefetchingDelegate = self
    }
    
    public var mediaIDs: [String] {
        return mediaList.itemIDsBeforeFirstGap
    }
    
    public var mediaCount: Int {
        return mediaList.mediaCount
    }
    
    public func mediaItem(for id: String, completion: @escaping (MediaItem?)->Void) {
        mediaList.mediaItem(for: id, completion: completion)
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
    
    public func updateMediaItemInMemCache(for id: String) {
        mediaList.updateMediaItemInMemCache(for: id)
    }
    
    public func updateMediaItemInMemCache(with mediaItem: MediaItem) {
        mediaList.updateMediaItemInMemCache(with: mediaItem)
    }
    
    public func fetchUpdatedPost(for code: String, completion: ((MediaItem)->())? = nil, failure: (()->())? = nil) {
        feedWebStore.fetchUpdatedMediaItem(for: code, completion: { [weak self] (mediaItem) in
            
            self?.mediaDataStore.archiveMedia([mediaItem])
            self?.updateMediaItemInMemCache(for: mediaItem.id)
            completion?(mediaItem)
            
        }, failure: failure)
    }
}

extension FeedManager: ScrollingMediaListPrefetchingDelegate {
    
    func scrollingMediaList(_ scrollingMediaList: ScrollingMediaList, prefetchDataFor mediaItems: [MediaItem]) {
        prefetchingDelegate?.feedManager(self, prefetchDataFor: mediaItems)
    }
    
    func scrollingMediaList(_ scrollingMediaList: ScrollingMediaList, removeCachedDataFor mediaItems: [MediaItem]) {
        prefetchingDelegate?.feedManager(self, removeCachedDataFor: mediaItems)
    }
}

extension FeedManager: MediaDataStoreObserver {
    
    func mediaDataStore(_ sender: MediaDataStore, didArchiveNewMedia newMedia: [MediaItem]) {
        for newMediaItem in newMedia {
            updateMediaItemInMemCache(with: newMediaItem)
        }
        prefetchingDelegate?.feedManager(self, updatedMediaItems: newMedia)
    }

}
