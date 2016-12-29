//
//  Media.swift
//  InstagramData
//
//  Created by Ben Davis on 28/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import SwiftyJSON

public struct MediaItem {
    
    let id: String
    
    let date: Date
    let dimensions: CGSize
    let ownerId: String
    let code: String?
    let isVideo: Bool
    
    let thumbnail: URL
    let display: URL
    
    let commentsDisabled: Bool
    let commentsCount: Int
//    let comments: [Any]?
    let likesCount: Int
    
    init(jsonDictionary: [String: Any]) {
        
        let json = JSON(jsonDictionary)
        
        id = json["id"].stringValue
            
        date = json["date"].dateValue
        dimensions = json["dimensions"].sizeValue
        ownerId = json["owner"]["id"].stringValue
        code = json["code"].string
        isVideo = json["is_video"].boolValue
            
        thumbnail = json["thumbnail_src"].URLWithoutEscaping!
        display = json["display_src"].URLWithoutEscaping!
            
        commentsDisabled = json["comments_disabled"].boolValue
        commentsCount = json["comments"]["count"].intValue
        likesCount = json["likes"]["count"].intValue

    }
}
