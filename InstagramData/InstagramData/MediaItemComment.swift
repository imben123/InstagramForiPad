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
    public let userId: String
    public let userName: String
    public let profilePicture: URL
    
    public static func ==(lhs: MediaItemComment, rhs: MediaItemComment) -> Bool {
        return (
            lhs.id == rhs.id &&
            lhs.text == rhs.text &&
            lhs.userId == rhs.userId &&
            lhs.userName == rhs.userName &&
            lhs.profilePicture == rhs.profilePicture
        )
    }

    public init(jsonDictionary json: JSON) {
                
        self.id = json["id"].stringValue
        self.text = json["text"].stringValue
        self.userId = json["user"]["id"].stringValue
        self.userName = json["user"]["username"].stringValue
        self.profilePicture = json["user"]["profile_pic_url"].URLWithoutEscaping!.bySettingScheme(to: "https")

    }
}
