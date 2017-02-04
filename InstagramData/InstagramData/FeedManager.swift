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
}

public class FeedManager {
    
    public weak var prefetchingDelegate: FeedManagerPrefetchingDelegate?
    
    private let feedWebStore: FeedWebStore
    private let mediaDataStore: MediaDataStore
    private let mediaList: ScrollingMediaList
    private var endCursor: String? {
        return mediaList.firstGapCursor
    }
    
    convenience init(communicator: APICommunicator) {
        let mediaList = ScrollingMediaList(name: "feed",
                                           pageSize: 50,
                                           mediaDataStore: MediaDataStore(),
                                           listDataStore: GappedListDataStore())
        
        self.init(communicator: communicator, mediaList: mediaList)
    }
    
    init(communicator: APICommunicator, mediaList: ScrollingMediaList) {
        self.mediaDataStore = MediaDataStore()
        self.mediaList = mediaList
        self.feedWebStore = FeedWebStore(communicator: communicator)
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
