//
//  FeedManager.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
import SwiftyJSON

public class FeedManager {
    
    let feedWebStore: FeedWebStore
    
    private let mediaList: MediaList
    public var media: [MediaItem] {
        return mediaList.media
    }
    
    private var endCursor: String? {
        return mediaList.endCursor
    }
    
    init(communicator: APICommunicator) {
        self.mediaList = MediaList(dataStore: MediaListDataStore(mediaOrigin: "feed"))
        self.feedWebStore = FeedWebStore(communicator: communicator)
    }
    
    init(communicator: APICommunicator, mediaList: MediaList) {
        self.mediaList = mediaList
        self.feedWebStore = FeedWebStore(communicator: communicator)
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

}
