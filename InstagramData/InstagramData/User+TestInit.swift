//
//  User+TestInit.swift
//  InstagramData
//
//  Created by Ben Davis on 30/07/2019.
//  Copyright © 2019 bendavisapps. All rights reserved.
//

import Foundation

extension User {
    init(id: String,
         profilePictureURL: URL,
         fullName: String,
         username: String,
         biography: String,
         externalURL: URL?,
         mediaCount: Int,
         followedByCount: Int,
         followsCount: Int,
         followedByViewer: Bool,
         followsViewer: Bool) {
        self.id = id
        self.profilePictureURL = profilePictureURL
        self.fullName = fullName
        self.username = username
        self.biography = biography
        self.externalURL = externalURL
        self.mediaCount = mediaCount
        self.followedByCount = followedByCount
        self.followsCount = followsCount
        self.followedByViewer = followedByViewer
        self.followsViewer = followsViewer
    }
}
