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
    dynamic var owner: UserTableRow?
    dynamic var code: String = ""
    dynamic var isVideo: Bool = false

    dynamic var caption: String?

    dynamic var displayURL: String = ""
    dynamic var thumbnailURL: String = ""
    
    dynamic var commentsDisabled: Bool = false
    dynamic var commentsCount: Int = 0
    dynamic var commentsStartCursor: String?
    let comments = List<MediaItemCommentTableRow>()
    dynamic var likesCount: Int = 0
    dynamic var viewerHasLiked: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension MediaItemTableRow {
    
    convenience init(_ mediaItem: MediaItem) {
        self.init()
        
        self.id = mediaItem.id
        
        self.date = mediaItem.date
        self.dimensionsWidth = Int(mediaItem.dimensions.width)
        self.dimensionsHeight = Int(mediaItem.dimensions.height)
        self.owner = UserTableRow(mediaItem.owner)
        self.code = mediaItem.code
        self.isVideo = mediaItem.isVideo
        
        self.caption = mediaItem.caption
        
        self.thumbnailURL = mediaItem.thumbnail.absoluteString
        self.displayURL = mediaItem.display.absoluteString
        
        self.commentsDisabled = mediaItem.commentsDisabled
        self.commentsCount = mediaItem.commentsCount
        self.commentsStartCursor = mediaItem.commentsStartCursor
        
        for comment in mediaItem.comments {
            self.comments.append(MediaItemCommentTableRow(comment))
        }
        self.likesCount = mediaItem.likesCount
        self.viewerHasLiked = mediaItem.viewerHasLiked
    }
}

extension MediaItem {
    
    init(_ mediaItemTableRow: MediaItemTableRow) {
        
        id = mediaItemTableRow.id
        
        date = mediaItemTableRow.date
        dimensions = CGSize(width: mediaItemTableRow.dimensionsWidth, height: mediaItemTableRow.dimensionsHeight)
        owner = User(mediaItemTableRow.owner!)
        code = mediaItemTableRow.code
        isVideo = mediaItemTableRow.isVideo
        
        caption = mediaItemTableRow.caption
        
        display = URL(string: mediaItemTableRow.displayURL)!
        thumbnail = URL(string: mediaItemTableRow.thumbnailURL)!
        
        commentsDisabled = mediaItemTableRow.commentsDisabled
        commentsCount = mediaItemTableRow.commentsCount
        commentsStartCursor = mediaItemTableRow.commentsStartCursor
        comments = mediaItemTableRow.comments.map({ (row) -> MediaItemComment in
            return MediaItemComment(row)
        })
        likesCount = mediaItemTableRow.likesCount
        viewerHasLiked = mediaItemTableRow.viewerHasLiked
    }
}

