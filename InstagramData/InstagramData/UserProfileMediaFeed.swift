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

    init(user: User, communicator: APICommunicator, mediaDataStore: MediaDataStore) {
        
        let mediaList = ScrollingMediaList(name: "user_feed(\(user.id))",
                                           mediaDataStore: mediaDataStore,
                                           listDataStore: GappedListDataStore())
        
        let feedWebStore = UserProfileMediaFeedWebStore(user: user, communicator: communicator)
        
        super.init(mediaList: mediaList, feedWebStore: feedWebStore)
    }
}

class UserProfileMediaFeedWebStore {
    
    fileprivate let numberOfPostsToFetch = 50

    fileprivate let user: User
    fileprivate let communicator: APICommunicator
    fileprivate let taskDispatcher: TaskDispatcher
    
    convenience init(user: User, communicator: APICommunicator) {
        let taskDispatcher = TaskDispatcher(queue: DispatchQueue(label: "UserProfileMediaFeedWebStore.queue"))
        self.init(user: user,
                  communicator: communicator,
                  taskDispatcher: taskDispatcher)
    }
    
    init(user: User, communicator: APICommunicator, taskDispatcher: TaskDispatcher) {
        self.user = user
        self.communicator = communicator
        self.taskDispatcher = taskDispatcher
    }
}

// Rewrite this class functionally as it's basically the same as the feed one??
extension UserProfileMediaFeedWebStore: MediaListWebStore {
    
    func fetchNewestMedia(_ completion: ((_ newMedia: [MediaItem], _ endCursor: String?)->())?,
                          failure: (()->())?) {
        taskDispatcher.async {
            let response = self.communicator.getUserFeed(username: self.user.username,
                                                         userId: self.user.id, 
                                                         numberOfPosts: self.numberOfPostsToFetch, 
                                                         from: nil)
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
            let response = self.communicator.getUserFeed(username: self.user.username,
                                                         userId: self.user.id,  
                                                         numberOfPosts: self.numberOfPostsToFetch,
                                                         from: endCursor)
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
        let mediaItemDictionariesNodes = json["data"]["user"]["edge_owner_to_timeline_media"]["edges"].arrayValue        
        let mediaItemDictionaries = mediaItemDictionariesNodes.map { $0["node"] }
        for mediaDictionary in mediaItemDictionaries {
            let mediaItem = MediaItem(jsonDictionary: mediaDictionary.dictionaryObject!, owner: user)
            result.append(mediaItem)
        }
        
        return result
    }
    
    private func parseEndCursor(from response: APIResponse) -> String? {
        let json = JSON(response.responseBody!)
        let pageInfo = json["data"]["user"]["edge_owner_to_timeline_media"]["page_info"]
        
        guard pageInfo["has_next_page"].boolValue else {
            return nil
        }
        return pageInfo["end_cursor"].stringValue
    }
}
