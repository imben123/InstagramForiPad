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
    
    let communicator: APICommunicator
    let taskDispatcher: TaskDispatcher
    var numberOfPostsToFetch = 30
    
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
                
                let startCursor = self.parseStartCursor(from: response)
                guard startCursor == endCursor else {
                    print("End cursor rejected by Instagram API")
                    failure?()
                    return
                }
                
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
    
    func fetchUpdatedMediaItem(for code: String, completion: @escaping (MediaItem)->(), failure: (()->())?) {
        taskDispatcher.async {
            let response = self.communicator.getPost(with: code)
            if response.succeeded {
                let mediaDictionary = response.responseBody!["media"] as! [String: Any]
                let mediaItem = MediaItem(jsonDictionary: mediaDictionary)
                self.taskDispatcher.asyncOnMainQueue {
                    completion(mediaItem)
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
        let mediaItemDictionaries = json["feed"]["media"]["nodes"].arrayValue
        for mediaDictionary in mediaItemDictionaries {
            let mediaItem = MediaItem(jsonDictionary: mediaDictionary.dictionaryObject!)
            result.append(mediaItem)
        }
        
        return result
    }
    
    private func parseStartCursor(from response: APIResponse) -> String? {
        let json = JSON(response.responseBody!)
        
        return json["feed"]["media"]["page_info"]["start_cursor"].stringValue
    }
    
    private func parseEndCursor(from response: APIResponse) -> String? {
        let json = JSON(response.responseBody!)
        
        guard json["feed"]["media"]["page_info"]["has_next_page"].boolValue else {
            return nil
        }
        return json["feed"]["media"]["page_info"]["end_cursor"].stringValue
    }

}
