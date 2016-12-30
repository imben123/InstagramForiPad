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
    
    public var media: [MediaItem] = []
    
    init(communicator: APICommunicator) {
        self.communicator = communicator
    }
    
    public func fetchMoreMedia(_ completion: (()->())?, failure: (()->())? = nil) {
        let response = self.communicator.getFeed()
        if response.succeeded {
            media.append(contentsOf: parseMedia(from: response))
            DispatchQueue.main.async {
                completion?()
            }
        } else {
            DispatchQueue.main.async {
                failure?()
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

}
