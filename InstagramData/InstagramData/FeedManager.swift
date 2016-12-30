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
    var numberOfPostsToFetch = 10
    
    public var media: [MediaItem] = []
    private var endCursor: String? = nil
    
    init(communicator: APICommunicator) {
        self.communicator = communicator
    }
    
    public func fetchMoreMedia(_ completion: (()->())?, failure: (()->())? = nil) {
        DispatchQueue.global().async {
            let response = self.communicator.getFeed(numberOfPosts: self.numberOfPostsToFetch, from: self.endCursor)
            if response.succeeded {
                self.media.append(contentsOf: self.parseMedia(from: response))
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
        
        // For next request
        endCursor = json["feed"]["media"]["page_info"]["end_cursor"].string
        
        return result
    }

}
