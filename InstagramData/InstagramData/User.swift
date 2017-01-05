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
    public let biography: String?
    public let externalURL: URL?

    public let media: [MediaItem]?
    public let totalNumberOfMediaItems: Int?

    init(jsonDictionary: [String: Any]) {
        
        let json = JSON(jsonDictionary)
        
        id = json["id"].stringValue

        profilePictureURL = json["profile_pic_url"].URLWithoutEscaping!.bySettingScheme(to: "https")
        fullName = json["full_name"].stringValue
        username = json["username"].stringValue
        biography = json["biography"].string
        externalURL = json["external_url"].URLWithoutEscaping
        
        media = User.parseMediaItems(json)
        totalNumberOfMediaItems = json["media"]["count"].intValue
    }
    
    private static func parseMediaItems(_ json: JSON) -> [MediaItem]? {
        
        let mediaJson = json["media"]
        guard mediaJson.exists() else {
            return nil
        }
        
        let mediaNodes = mediaJson["nodes"].arrayObject as! [ [String: Any] ]
        var result: [MediaItem] = []
        for node in mediaNodes {
            result.append(MediaItem(jsonDictionary: node as [String: Any]))
        }
        return result
    }
    
    public static func ==(lhs: User, rhs: User) -> Bool {
        return (
            lhs.id == rhs.id &&
            lhs.profilePictureURL == rhs.profilePictureURL &&
            lhs.fullName == rhs.fullName &&
            lhs.username == rhs.username &&
            lhs.biography == rhs.biography &&
            lhs.externalURL == rhs.externalURL &&
            lhs.totalNumberOfMediaItems == rhs.totalNumberOfMediaItems
        )
    }
}
