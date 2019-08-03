//
//  FeedWebStore.swift
//  InstagramData
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftToolbox

class FeedWebStore: MediaListWebStore {
    
    private let communicator: APICommunicator
    private let taskDispatcher: TaskDispatcher
    var numberOfPostsToFetch = 50
    
    convenience init(communicator: APICommunicator) {
        let taskDispatcher = TaskDispatcher(queue: DispatchQueue(label: "FeedWebStore.queue"))
        self.init(communicator: communicator, taskDispatcher: taskDispatcher)
    }
    
    init(communicator: APICommunicator, taskDispatcher: TaskDispatcher) {
        self.communicator = communicator
        self.taskDispatcher = taskDispatcher
    }

    func fetchNewestMedia(_ completion: ((_ newMedia: [MediaItem], _ endCursor: String?)->())?, failure: (()->())?) {
        taskDispatcher.async {
            let response = self.communicator.getFeed(numberOfPosts: self.numberOfPostsToFetch, from: nil)
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
    
    func fetchMedia(after endCursor: String, completion: ((_ newMedia: [MediaItem], _ endCursor: String?)->())?, failure: (()->())?) {
        
        taskDispatcher.async {
            let response = self.communicator.getFeed(numberOfPosts: self.numberOfPostsToFetch, from: endCursor)
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
        let mediaItemNodes = json["data"]["user"]["edge_web_feed_timeline"]["edges"].arrayValue
        let mediaItemDictionaries = mediaItemNodes.map { $0["node"] }
        for mediaDictionary in mediaItemDictionaries {
            let mediaItem = MediaItem(jsonDictionary: mediaDictionary.dictionaryObject!)
            result.append(mediaItem)
        }
        
        return result
    }
    
    private func parseEndCursor(from response: APIResponse) -> String? {
        let json = JSON(response.responseBody!)
                
        guard json["data"]["user"]["edge_web_feed_timeline"]["page_info"]["has_next_page"].boolValue else {
            return nil
        }
        return json["data"]["user"]["edge_web_feed_timeline"]["page_info"]["end_cursor"].stringValue
    }
}
