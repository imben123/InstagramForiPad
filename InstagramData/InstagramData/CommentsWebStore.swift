//
//  CommentsWebStore.swift
//  InstagramData
//
//  Created by Ben Davis on 04/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import Foundation
import SwiftyJSON

class CommentsWebStore {
    
    let communicator: APICommunicator
    var numberOfPostsToFetch = 10
    
    init(communicator: APICommunicator) {
        self.communicator = communicator
    }
    
    func getComments(for mediaCode: String,
                     from previousIndex: String,
                     completion: ((_ newMedia: [MediaItemComment], _ endCursor: String?)->())?,
                     failure: (()->())?) {
        
        DispatchQueue.global().async {
            
            let response = self.communicator.getComments(for: mediaCode,
                                                         numberOfComments: self.numberOfPostsToFetch,
                                                         from: previousIndex)
            
            if response.succeeded {
                
                let newEndCursor = self.parseEndCursor(from: response)
                let newComments = self.parseComments(from: response)

                DispatchQueue.main.async {
                    completion?(newComments, newEndCursor)
                }

            } else {
                DispatchQueue.main.async {
                    failure?()
                }
            }
        }
    }
    
    private func parseComments(from response: APIResponse) -> [MediaItemComment] {
        
        let json = JSON(response.responseBody!)
        
        var result: [MediaItemComment] = []

        let commentsNodes = json["data"]["shortcode_media"]["edge_media_to_parent_comment"]["edges"].arrayValue
        let commentsDictionaries = commentsNodes.map { $0["node"] }
        for commentDictionary in commentsDictionaries {
            let comment = MediaItemComment(jsonDictionary: commentDictionary)
            result.append(comment)
        }
        
        return result
    }
    
    private func parseEndCursor(from response: APIResponse) -> String? {
        let json = JSON(response.responseBody!)
        let pageInfo = json["data"]["shortcode_media"]["edge_media_to_parent_comment"]["page_info"]
        
        guard pageInfo["has_next_page"].boolValue else {
            return nil
        }
        return pageInfo["end_cursor"].stringValue
    }
}
