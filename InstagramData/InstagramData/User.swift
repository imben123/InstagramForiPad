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

public class User {
    
    let id: String
    
    let profilePictureURL: URL?
    let fullName: String
    let username: String
    let biography: String?
    let externalURL: URL?
    let connectedFacebookPage: Any?

    let followedByCount: Int
    let followsCount: Int

    let followsViewer: Bool
    let followedByViewer: Bool
    let requestedByViewer: Bool
    let hasRequestedViewer: Bool
    
    let hasBlockedViewer: Bool
    let blockedByViewer: Bool
    let isPrivate: Bool
    let isVerified: Bool

    let media: [MediaItem]

    public init(jsonDictionary: [String: Any]) {
        
        let json = JSON(jsonDictionary)
        
        id = json["id"].stringValue

        profilePictureURL = json["profile_pic_url"].URLWithoutEscaping
        fullName = json["full_name"].stringValue
        username = json["username"].stringValue
        biography = json["biography"].string
        externalURL = json["external_url"].URLWithoutEscaping
        connectedFacebookPage = json["connected_fb_page"].object
        
        followedByCount = json["followed_by"]["count"].intValue
        followsCount = json["follows"]["count"].intValue

        followsViewer = json["follows_viewer"].boolValue
        followedByViewer = json["followed_by_viewer"].boolValue
        requestedByViewer = json["requested_by_viewer"].boolValue
        hasRequestedViewer = json["has_requested_viewer"].boolValue
        
        hasBlockedViewer = json["has_blocked_viewer"].boolValue
        blockedByViewer = json["blocked_by_viewer"].boolValue
        isPrivate = json["is_private"].boolValue
        isVerified = json["is_verified"].boolValue
        
        media = User.parseMediaItems(json)
    }
    
    private class func parseMediaItems(_ json: JSON) -> [MediaItem] {
        let mediaJson = json["media"]
        let mediaNodes = mediaJson["nodes"].arrayObject as! [ [String: Any] ]
        var result: [MediaItem] = []
        for node in mediaNodes {
            result.append(MediaItem(jsonDictionary: node as [String: Any]))
        }
        return result
    }
}
