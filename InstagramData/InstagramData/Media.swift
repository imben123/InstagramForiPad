//
//  Media.swift
//  InstagramData
//
//  Created by Ben Davis on 28/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import SwiftyJSON

public struct MediaItem: Equatable {
    
    public let id: String
    
    public let date: Date
    public let dimensions: CGSize
    public let owner: User
    public let code: String?
    public let isVideo: Bool
    
    public let display: URL
    public let thumbnail: URL
    
    public let commentsDisabled: Bool
    public let commentsCount: Int
//    let comments: [Any]?
    public let likesCount: Int
    
    init(jsonDictionary: [String: Any]) {
        
        let json = JSON(jsonDictionary)
        
        id = json["id"].stringValue
        
        date = json["date"].dateValue
        dimensions = json["dimensions"].sizeValue
        owner = User(jsonDictionary: json["owner"].dictionaryObject!)
        code = json["code"].string
        isVideo = json["is_video"].boolValue
            
        display = json["display_src"].URLWithoutEscaping!
        thumbnail = (json["thumbnail_src"].URLWithoutEscaping != nil) ? json["thumbnail_src"].URLWithoutEscaping! : display
        
        commentsDisabled = json["comments_disabled"].boolValue
        commentsCount = json["comments"]["count"].intValue
        likesCount = json["likes"]["count"].intValue
    }
    
    init(jsonDictionary: [String: Any], owner: User) {
        
        let json = JSON(jsonDictionary)
        
        self.id = json["id"].stringValue
        
        self.date = json["date"].dateValue
        self.dimensions = json["dimensions"].sizeValue
        self.owner = owner
        self.code = json["code"].string
        self.isVideo = json["is_video"].boolValue
        
        self.display = json["display_src"].URLWithoutEscaping!
        self.thumbnail = (json["thumbnail_src"].URLWithoutEscaping != nil) ? json["thumbnail_src"].URLWithoutEscaping! : display
        
        self.commentsDisabled = json["comments_disabled"].boolValue
        self.commentsCount = json["comments"]["count"].intValue
        self.likesCount = json["likes"]["count"].intValue
    }
    
    public static func ==(lhs: MediaItem, rhs: MediaItem) -> Bool {
        return (
            lhs.id == rhs.id &&
            lhs.date == rhs.date &&
            lhs.dimensions == rhs.dimensions &&
            lhs.owner == rhs.owner &&
            lhs.code == rhs.code &&
            lhs.isVideo == rhs.isVideo &&
            lhs.thumbnail == rhs.thumbnail &&
            lhs.display == rhs.display &&
            lhs.commentsDisabled == rhs.commentsDisabled &&
            lhs.commentsCount == rhs.commentsCount &&
            lhs.likesCount == rhs.likesCount
        )
    }

}
