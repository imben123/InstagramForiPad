//
//  StubbedModels.swift
//  InstagramData
//
//  Created by Ben Davis on 04/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import Foundation
@testable import InstagramData

extension User {
    init(id: String) {
        self.id = id
        self.profilePictureURL = URL(string: "https://google.com")!
        self.fullName = "Full name"
        self.username = "username"
        self.biography = "This is a user biography"
        self.externalURL = URL(string: "https://google.com")!
        self.media = []
        self.totalNumberOfMediaItems = 0
    }
}

extension MediaItem {
    init(id: String) {
        self.id = id
        self.date = Date(timeIntervalSince1970: 0)
        self.dimensions = CGSize.zero
        self.owner = User(id: "123")
        self.code = ""
        self.isVideo = false
        self.display = URL(string: "https://google.com")!
        self.thumbnail = display
        self.commentsDisabled = false
        self.commentsCount = 0
        self.commentsStartCursor = ""
        self.likesCount = 0
        self.viewerHasLiked = false
        self.caption = nil
        self.comments = []
    }
}
