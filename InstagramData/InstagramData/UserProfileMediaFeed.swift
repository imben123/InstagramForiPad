//
//  UserProfileMediaFeed.swift
//  InstagramData
//
//  Created by Ben Davis on 26/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftToolbox

public class UserProfileMediaFeed: MediaFeed {

    init(userId: String, communicator: APICommunicator, mediaDataStore: MediaDataStore) {
        
        let mediaList = ScrollingMediaList(name: "user_feed(\(userId))",
                                           mediaDataStore: mediaDataStore,
                                           listDataStore: GappedListDataStore())
        
        let feedWebStore = UserProfileMediaFeedWebStore(userId: userId, communicator: communicator)
        
        super.init(mediaList: mediaList, feedWebStore: feedWebStore)
    }
}

class UserProfileMediaFeedWebStore {
    
    fileprivate let numberOfPostsToFetch = 50

    fileprivate let userId: String
    fileprivate let communicator: APICommunicator
    fileprivate let taskDispatcher: TaskDispatcher
    
    convenience init(userId: String, communicator: APICommunicator) {
        let taskDispatcher = TaskDispatcher(queue: DispatchQueue(label: "UserProfileMediaFeedWebStore.queue"))
        self.init(userId: userId, communicator: communicator, taskDispatcher: taskDispatcher)
    }
    
    init(userId: String, communicator: APICommunicator, taskDispatcher: TaskDispatcher) {
        self.userId = userId
        self.communicator = communicator
        self.taskDispatcher = taskDispatcher
    }
}

// Rewrite this class functionally as it's basically the same as the feed one??
extension UserProfileMediaFeedWebStore: MediaListWebStore {
    
    func fetchNewestMedia(_ completion: ((_ newMedia: [MediaItem], _ endCursor: String?)->())?,
                          failure: (()->())?) {
        taskDispatcher.async {
            let response = self.communicator.getUserFeed(userId: self.userId, numberOfPosts: self.numberOfPostsToFetch, from: nil)
            if response.succeeded {
                
                let newMedia = self.parseMedia(from: response)
                let newEndCursor = self.parseEndCursor(from: response)
                
                self.taskDispatcher.asyncOnMainQueue {
                    completion?(newMedia, newEndCursor)
                }
            } else {
                self.taskDispatcher.asyncOnMainQueue {
                    failure?()
                }
            }
        }
    }
    
    func fetchMedia(after endCursor: String,
                    completion: ((_ newMedia: [MediaItem], _ endCursor: String?)->())?,
                    failure: (()->())?) {
        taskDispatcher.async {
            let response = self.communicator.getUserFeed(userId: self.userId, numberOfPosts: self.numberOfPostsToFetch, from: endCursor)
            if response.succeeded {
                
                let newEndCursor = self.parseEndCursor(from: response)
                let newMedia = self.parseMedia(from: response)
                
                self.taskDispatcher.asyncOnMainQueue {
                    completion?(newMedia, newEndCursor)
                }
            } else {
                self.taskDispatcher.asyncOnMainQueue {
                    failure?()
                }
            }
        }
    }
    
    private func parseMedia(from response: APIResponse) -> [MediaItem] {
        
        var result: [MediaItem] = []
        let json = JSON(response.responseBody!)
        let mediaItemDictionaries = json["media"]["nodes"].arrayValue
        for mediaDictionary in mediaItemDictionaries {
            let mediaItem = MediaItem(jsonDictionary: mediaDictionary.dictionaryObject!)
            result.append(mediaItem)
        }
        
        return result
    }
    
    private func parseStartCursor(from response: APIResponse) -> String? {
        let json = JSON(response.responseBody!)
        
        return json["media"]["page_info"]["start_cursor"].stringValue
    }
    
    private func parseEndCursor(from response: APIResponse) -> String? {
        let json = JSON(response.responseBody!)
        
        guard json["media"]["page_info"]["has_next_page"].boolValue else {
            return nil
        }
        return json["media"]["page_info"]["end_cursor"].stringValue
    }
}
