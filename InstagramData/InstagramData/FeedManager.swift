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
    
    let communicator: APICommunicator
    var numberOfPostsToFetch = 20
    
    private let mediaList: MediaList
    public var media: [MediaItem] {
        return mediaList.media
    }
    
    private var endCursor: String? {
        return mediaList.endCursor
    }
    
    init(communicator: APICommunicator) {
        self.mediaList = MediaList(dataStore: MediaListDataStore(mediaOrigin: "feed"))
        self.communicator = communicator
    }
    
    init(communicator: APICommunicator, mediaList: MediaList) {
        self.mediaList = mediaList
        self.communicator = communicator
    }
    
    public func fetchNewestMedia(_ completion: (()->())?, failure: (()->())? = nil) {
        DispatchQueue.global().async {
            let response = self.communicator.getFeed(numberOfPosts: self.numberOfPostsToFetch, from: nil)
            if response.succeeded {
                
                let newMedia = self.parseMedia(from: response)
                let newEndCursor = self.parseEndCursor(from: response)
                self.mediaList.addNewMedia(newMedia, with: newEndCursor)
                
                DispatchQueue.main.async {
                    completion?()
                }
            } else {
                DispatchQueue.main.async {
                    failure?()
                }
            }
        }
    }
    
    public func fetchMoreMedia(_ completion: (()->())?, failure: (()->())? = nil) {
        guard let currentEndCursor = self.endCursor else {
            fetchNewestMedia(completion, failure: failure)
            return
        }
        
        DispatchQueue.global().async {
            let response = self.communicator.getFeed(numberOfPosts: self.numberOfPostsToFetch, from: currentEndCursor)
            if response.succeeded {

                let newEndCursor = self.parseEndCursor(from: response)
                let newMedia = self.parseMedia(from: response)
                self.mediaList.appendMoreMedia(newMedia, from: currentEndCursor, to: newEndCursor)
                
                DispatchQueue.main.async {
                    completion?()
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
    
    
    private func parseEndCursor(from response: APIResponse) -> String {
        let json = JSON(response.responseBody!)
        return json["feed"]["media"]["page_info"]["end_cursor"].stringValue
    }

}
