//
//  FeedWebStore.swift
//  InstagramData
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
import SwiftyJSON

class FeedWebStore: MediaListWebStore {
    
    let communicator: APICommunicator
    var numberOfPostsToFetch = 100
    
    init(communicator: APICommunicator) {
        self.communicator = communicator
    }

    func fetchNewestMedia(_ completion: ((_ newMedia: [MediaItem], _ endCursor: String)->())?, failure: (()->())?) {
        DispatchQueue.global().async {
            let response = self.communicator.getFeed(numberOfPosts: self.numberOfPostsToFetch, from: nil)
            if response.succeeded {
                
                let newMedia = self.parseMedia(from: response)
                let newEndCursor = self.parseEndCursor(from: response)
                
                DispatchQueue.main.async {
                    completion?(newMedia, newEndCursor)
                }
            } else {
                DispatchQueue.main.async {
                    failure?()
                }
            }
        }
    }
    
    func fetchMedia(after endCursor: String, completion: ((_ newMedia: [MediaItem], _ endCursor: String)->())?, failure: (()->())?) {
        
        DispatchQueue.global().async {
            let response = self.communicator.getFeed(numberOfPosts: self.numberOfPostsToFetch, from: endCursor)
            if response.succeeded {
                
                let startCursor = self.parseStartCursor(from: response)
                guard startCursor == endCursor else {
                    print("End cursor rejected by Instagram API... Probably returned new media instead")
                    failure?()
                    return
                }
                
                let newEndCursor = self.parseEndCursor(from: response)
                let newMedia = self.parseMedia(from: response)
                
                DispatchQueue.main.async {
                    completion?(newMedia, newEndCursor)
                }
            } else {
                DispatchQueue.main.async {
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
    
    private func parseStartCursor(from response: APIResponse) -> String {
        let json = JSON(response.responseBody!)
        return json["feed"]["media"]["page_info"]["start_cursor"].stringValue
    }
    
    private func parseEndCursor(from response: APIResponse) -> String {
        let json = JSON(response.responseBody!)
        return json["feed"]["media"]["page_info"]["end_cursor"].stringValue
    }

}
