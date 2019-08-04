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
    
    public static func ==(lhs: MediaItemComment, rhs: MediaItemComment) -> Bool {
        return (
            lhs.id == rhs.id &&
            lhs.text == rhs.text &&
            lhs.user == rhs.user
        )
    }

    public init(jsonDictionary json: JSON) {
                
        self.id = json["id"].stringValue
        self.text = json["text"].stringValue
        self.user = User(json: json["owner"])

    }
    
    public init(_ id: String,
                text: String,
                user: User) {
        self.id = id
        self.text = text
        self.user = user
    }
}
