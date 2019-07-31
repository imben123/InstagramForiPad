//
//  MediaItem+TestInit.swift
//  InstagramData
//
//  Created by Ben Davis on 30/07/2019.
//  Copyright © 2019 bendavisapps. All rights reserved.
//

import Foundation

extension MediaItem {
    init(id: String,
         date: Date,
         dimensions: CGSize,
         owner: User,
         code: String,
         isVideo: Bool,
         caption: String?,
         display: URL,
         thumbnail: URL,
         commentsDisabled: Bool,
         commentsCount: Int,
         commentsStartCursor: String?,
         comments: [MediaItemComment],
         likesCount: Int,
         viewerHasLiked: Bool) {
        self.id = id
        self.date = date
        self.dimensions = dimensions
        self.owner = owner
        self.code = code
        self.isVideo = isVideo
        self.caption = caption
        self.display = display
        self.thumbnail = thumbnail
        self.commentsDisabled = commentsDisabled
        self.commentsCount = commentsCount
        self.commentsStartCursor = commentsStartCursor
        self.comments = comments
        self.likesCount = likesCount
        self.viewerHasLiked = viewerHasLiked
    }
}
