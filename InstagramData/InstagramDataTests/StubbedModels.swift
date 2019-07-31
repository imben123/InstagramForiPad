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
        self.init(id: id,
                  profilePictureURL: URL(string: "https://google.com")!,
                  fullName: "Full name",
                  username: "username",
                  biography: "This is a user biography",
                  externalURL: URL(string: "https://google.com")!,
                  mediaCount: 123,
                  followedByCount: 456,
                  followsCount: 789,
                  followedByViewer: true,
                  followsViewer: true)
    }
}

extension MediaItem {
    init(id: String, code: String = "code") {
        self.init(id: id,
                  date: Date(timeIntervalSince1970: 0),
                  dimensions: .zero,
                  owner: User(id: "123"),
                  code: code,
                  isVideo: false,
                  caption: nil,
                  display: URL(string: "https://google.com")!,
                  thumbnail: URL(string: "https://google.com")!,
                  commentsDisabled: false,
                  commentsCount: 0,
                  commentsStartCursor: "",
                  comments: [],
                  likesCount: 0,
                  viewerHasLiked: false)
    }
}
