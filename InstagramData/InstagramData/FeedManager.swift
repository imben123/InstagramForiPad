//
//  FeedManager.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
import SwiftyJSON

public class FeedManager: MediaFeed {
    
    init(communicator: APICommunicator, mediaDataStore: MediaDataStore) {
        
        let mediaList = ScrollingMediaList(name: "feed",
                                           mediaDataStore: mediaDataStore,
                                           listDataStore: GappedListDataStore())
        
        let feedWebStore = FeedWebStore(communicator: communicator)
        
        super.init(mediaList: mediaList, feedWebStore: feedWebStore)
    }
}
