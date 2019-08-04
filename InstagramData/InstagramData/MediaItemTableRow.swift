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
    @objc dynamic var value: String = ""
    @objc dynamic var mediaOrigin: String = ""
}

class MediaItemTableRow: Object {
    
    @objc dynamic var id: String = ""
    
    @objc dynamic var date: Date = Date()
    @objc dynamic var dimensionsWidth: Int = 0
    @objc dynamic var dimensionsHeight: Int = 0
    @objc dynamic var owner: UserTableRow?
    @objc dynamic var code: String = ""
    @objc dynamic var isVideo: Bool = false

    @objc dynamic var caption: String?

    @objc dynamic var displayURL: String = ""
    @objc dynamic var thumbnailURL: String = ""
    
    @objc dynamic var commentsDisabled: Bool = false
    @objc dynamic var commentsCount: Int = 0
    @objc dynamic var commentsStartCursor: String?
    let comments = List<MediaItemCommentTableRow>()
    @objc dynamic var likesCount: Int = 0
    @objc dynamic var viewerHasLiked: Bool = false
    
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
        self.commentsStartCursor = mediaItem.commentsEndCursor
        
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
        commentsEndCursor = mediaItemTableRow.commentsStartCursor
        comments = mediaItemTableRow.comments.map({ (row) -> MediaItemComment in
            return MediaItemComment(row)
        })
        likesCount = mediaItemTableRow.likesCount
        viewerHasLiked = mediaItemTableRow.viewerHasLiked
    }
}

