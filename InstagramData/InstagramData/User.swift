//
//  User.swift
//  InstagramData
//
//  Created by Ben Davis on 28/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftToolbox

extension URL {
    func bySettingScheme(to scheme: String) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        components.scheme = scheme
        return components.url!
    }
}

public struct User: Equatable {
    
    public let id: String
    
    public let profilePictureURL: URL
    public let fullName: String
    public let username: String
    public let biography: String
    public let externalURL: URL?

    public let mediaCount: Int
    public let followedByCount: Int
    public let followsCount: Int
    
    public var followedByViewer: Bool
    public let followsViewer: Bool

    init(jsonDictionary: [String: Any]) {
        let json = JSON(jsonDictionary)
        self.init(json: json)
    }
    
    init(json: JSON) {
        
        id = json["id"].stringValue

        profilePictureURL = json["profile_pic_url"].URLWithoutEscaping!.bySettingScheme(to: "https")
        fullName = json["full_name"].stringValue
        username = json["username"].stringValue
        biography = json["biography"].stringValue
        externalURL = json["external_url"].URLWithoutEscaping
        
        mediaCount = json["media"]["count"].intValue
        followedByCount = json["followed_by"]["count"].intValue
        followsCount = json["follows"]["count"].intValue
        
        followedByViewer = json["followed_by_viewer"].boolValue
        followsViewer = json["follows_viewer"].boolValue
    }
    
    public static func ==(lhs: User, rhs: User) -> Bool {
        return (
            lhs.id == rhs.id &&
            lhs.profilePictureURL == rhs.profilePictureURL &&
            lhs.fullName == rhs.fullName &&
            lhs.username == rhs.username &&
            lhs.biography == rhs.biography &&
            lhs.externalURL == rhs.externalURL &&
            lhs.mediaCount == rhs.mediaCount &&
            lhs.followedByCount == rhs.followedByCount &&
            lhs.followsCount == rhs.followsCount &&
            lhs.followedByViewer == rhs.followedByViewer &&
            lhs.followsViewer == rhs.followsViewer
        )
    }
}
