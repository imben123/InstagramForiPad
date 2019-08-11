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
    public let likesCount: Int
    
    public var viewerHasLiked: Bool
    
    init(jsonDictionary: [String: Any], original: MediaItem? = nil, owner: User? = nil) {
        
        let json = JSON(jsonDictionary)
        
        self.id = json["id"].stringValue
        
        self.date = json["date"].dateValue
        self.dimensions = json["dimensions"].sizeValue
        self.owner = owner ?? User(json: json["owner"])
        self.code = json["shortcode"].stringValue
        self.isVideo = json["is_video"].boolValue
        
        self.caption = json["edge_media_to_caption"]["edges"][0]["node"]["text"].string

        self.display = json["display_url"].URLWithoutEscaping!
        if
            let thumbnails = json["thumbnail_resources"].array,
            let bestThumbnail = thumbnails.last?["src"].URLWithoutEscaping {
            self.thumbnail = bestThumbnail
        } else {
            self.thumbnail = display
        }
        
        self.commentsDisabled = json["comments_disabled"].boolValue
        self.commentsCount = json["edge_media_to_comment"]["count"].intValue
        self.likesCount = json["edge_media_preview_like"]["count"].intValue
        self.viewerHasLiked = json["viewer_has_liked"].boolValue
    }
}
