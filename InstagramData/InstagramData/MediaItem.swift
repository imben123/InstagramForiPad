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
    public let code: String
    public let isVideo: Bool
    
    public let caption: String?
    
    public let display: URL
    public let thumbnail: URL
    
    public let commentsDisabled: Bool
    public let commentsCount: Int
    public let commentsStartCursor: String?
    public let comments: [MediaItemComment]
    public let likesCount: Int
    
    public var viewerHasLiked: Bool
    
    init(jsonDictionary: [String: Any]) {
        
        let json = JSON(jsonDictionary)
        
        id = json["id"].stringValue
        
        date = json["date"].dateValue
        dimensions = json["dimensions"].sizeValue
        owner = User(jsonDictionary: json["owner"].dictionaryObject!)
        code = json["code"].stringValue
        isVideo = json["is_video"].boolValue
        
        caption = json["caption"].string
        
        display = json["display_src"].URLWithoutEscaping!
        thumbnail = (json["thumbnail_src"].URLWithoutEscaping != nil) ? json["thumbnail_src"].URLWithoutEscaping! : display
        
        commentsDisabled = json["comments_disabled"].boolValue
        commentsCount = json["comments"]["count"].intValue
        commentsStartCursor = json["comments"]["page_info"]["start_cursor"].string
        comments = json["comments"]["nodes"].arrayValue.reversed().map({ json in
            return MediaItemComment(jsonDictionary: json)
        })
        likesCount = json["likes"]["count"].intValue
        viewerHasLiked = json["likes"]["viewer_has_liked"].boolValue
    }
    
    init(jsonDictionary: [String: Any], original: MediaItem) {
        
        let json = JSON(jsonDictionary)
        
        id = json["id"].stringValue
        
        date = json["date"].dateValue
        dimensions = json["dimensions"].sizeValue
        owner = User(jsonDictionary: json["owner"].dictionaryObject!)
        code = json["code"].stringValue
        isVideo = json["is_video"].boolValue
        
        caption = json["caption"].string
        
        display = json["display_src"].URLWithoutEscaping!
        thumbnail = (json["thumbnail_src"].URLWithoutEscaping != nil) ? json["thumbnail_src"].URLWithoutEscaping! : original.thumbnail
        
        commentsDisabled = json["comments_disabled"].boolValue
        commentsCount = json["comments"]["count"].intValue
        commentsStartCursor = json["comments"]["page_info"]["start_cursor"].string
        comments = json["comments"]["nodes"].arrayValue.reversed().map({ json in
            return MediaItemComment(jsonDictionary: json)
        })
        likesCount = json["likes"]["count"].intValue
        viewerHasLiked = json["likes"]["viewer_has_liked"].boolValue
    }
    
    init(jsonDictionary: [String: Any], owner: User) {
        
        let json = JSON(jsonDictionary)
        
        self.id = json["id"].stringValue
        
        self.date = json["date"].dateValue
        self.dimensions = json["dimensions"].sizeValue
        self.owner = owner
        self.code = json["code"].stringValue
        self.isVideo = json["is_video"].boolValue
        
        self.caption = json["caption"].string

        self.display = json["display_src"].URLWithoutEscaping!
        self.thumbnail = (json["thumbnail_src"].URLWithoutEscaping != nil) ? json["thumbnail_src"].URLWithoutEscaping! : display
        
        self.commentsDisabled = json["comments_disabled"].boolValue
        self.commentsCount = json["comments"]["count"].intValue
        self.commentsStartCursor = json["comments"]["start_cursor"].string
        self.comments = json["comments"]["nodes"].arrayValue.reversed().map({ json in
            return MediaItemComment(jsonDictionary: json)
        })
        self.likesCount = json["likes"]["count"].intValue
        self.viewerHasLiked = json["likes"]["viewer_has_liked"].boolValue
    }
    
    public static func ==(lhs: MediaItem, rhs: MediaItem) -> Bool {
        return (
            lhs.id == rhs.id &&
            lhs.date == rhs.date &&
            lhs.dimensions == rhs.dimensions &&
            lhs.owner == rhs.owner &&
            lhs.code == rhs.code &&
            lhs.isVideo == rhs.isVideo &&
            lhs.caption == rhs.caption &&
            lhs.thumbnail == rhs.thumbnail &&
            lhs.display == rhs.display &&
            lhs.commentsDisabled == rhs.commentsDisabled &&
            lhs.commentsCount == rhs.commentsCount &&
            lhs.commentsStartCursor == rhs.commentsStartCursor &&
            lhs.likesCount == rhs.likesCount &&
            lhs.viewerHasLiked == rhs.viewerHasLiked
        )
    }

}
