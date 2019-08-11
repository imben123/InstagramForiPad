//
//  MediaItemComment.swift
//  InstagramData
//
//  Created by Ben Davis on 02/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import SwiftyJSON

public struct MediaItemComment: Equatable {
    
    public let id: String
    public let text: String
    public let user: User
    public let replies: [MediaItemComment]

    public init(jsonDictionary json: JSON) {
                
        self.id = json["id"].stringValue
        self.text = json["text"].stringValue
        self.user = User(json: json["owner"])
        if json["edge_threaded_comments"]["count"].intValue > 0 {
            let nodes = json["edge_threaded_comments"]["edges"].arrayValue
            self.replies = nodes.map({ $0["node"] }).map({ MediaItemComment(jsonDictionary: $0) })
        } else {
            self.replies = []
        }
    }
    
    public init(_ id: String,
                text: String,
                user: User,
                replies: [MediaItemComment]) {
        self.id = id
        self.text = text
        self.user = user
        self.replies = replies
    }
}
