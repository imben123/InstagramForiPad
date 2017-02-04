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
    var numberOfPostsToFetch = 20
    
    init(communicator: APICommunicator) {
        self.communicator = communicator
    }
    
    func getComments(for mediaCode: String,
                     from previousIndex: String,
                     completion: ((_ newMedia: [MediaItemComment], _ startCursor: String?)->())?,
                     failure: (()->())?) {
        
        DispatchQueue.global().async {
            
            let response = self.communicator.getComments(for: mediaCode,
                                                         numberOfComments: self.numberOfPostsToFetch,
                                                         from: previousIndex)
            
            if response.succeeded {
                
                let newStartCursor = self.parseStartCursor(from: response)
                let newComments = self.parseComments(from: response)

                DispatchQueue.main.async {
                    completion?(newComments, newStartCursor)
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

        let commentsDictionaries = json["comments"]["nodes"].arrayValue
        for commentDictionary in commentsDictionaries {
            let comment = MediaItemComment(jsonDictionary: commentDictionary)
            result.append(comment)
        }
        
        return result
    }
    
    private func parseStartCursor(from response: APIResponse) -> String? {
        let json = JSON(response.responseBody!)
        
        guard json["comments"]["page_info"]["has_previous_page"].boolValue else {
            return nil
        }
        return json["comments"]["page_info"]["start_cursor"].stringValue
    }
    
}
