//
//  MediaItemTableRow.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
import RealmSwift

class MediaDataStoreEndCursor: Object {
    dynamic var value: String = ""
    dynamic var mediaOrigin: String = ""
}

class MediaItemTableRow: Object {
    
    dynamic var id: String = ""
    
    dynamic var date: Date = Date()
    dynamic var dimensionsWidth: Int = 0
    dynamic var dimensionsHeight: Int = 0
    dynamic var ownerId: String = ""
    dynamic var code: String? = nil
    dynamic var isVideo: Bool = false
    
    dynamic var thumbnailURL: String? = nil
    dynamic var displayURL: String = ""
    
    dynamic var commentsDisabled: Bool = false
    dynamic var commentsCount: Int = 0
    dynamic var likesCount: Int = 0
    
    // Used to distinguish between feed media and user profile media
    dynamic var mediaOrigin: String = ""
    
}

extension MediaItemTableRow {
    
    convenience init(_ mediaItem: MediaItem, mediaOrigin: String) {
        self.init()
        
        self.id = mediaItem.id
        
        self.date = mediaItem.date
        self.dimensionsWidth = Int(mediaItem.dimensions.width)
        self.dimensionsHeight = Int(mediaItem.dimensions.height)
        self.ownerId = mediaItem.ownerId
        self.code = mediaItem.code
        self.isVideo = mediaItem.isVideo
        
        self.thumbnailURL = mediaItem.thumbnail?.absoluteString
        self.displayURL = mediaItem.display.absoluteString
        
        self.commentsDisabled = mediaItem.commentsDisabled
        self.commentsCount = mediaItem.commentsCount
        self.likesCount = mediaItem.likesCount
        
        self.mediaOrigin = mediaOrigin
    }
}

extension MediaItem {
    
    init(_ mediaItemTableRow: MediaItemTableRow) {
        
        id = mediaItemTableRow.id
        
        date = mediaItemTableRow.date
        dimensions = CGSize(width: mediaItemTableRow.dimensionsWidth, height: mediaItemTableRow.dimensionsHeight)
        ownerId = mediaItemTableRow.ownerId
        code = mediaItemTableRow.code
        isVideo = mediaItemTableRow.isVideo
        
        thumbnail = mediaItemTableRow.thumbnailURL != nil ? URL(string: mediaItemTableRow.thumbnailURL!)! : nil
        display = URL(string: mediaItemTableRow.displayURL)!
        
        commentsDisabled = mediaItemTableRow.commentsDisabled
        commentsCount = mediaItemTableRow.commentsCount
        likesCount = mediaItemTableRow.likesCount
    }
}

