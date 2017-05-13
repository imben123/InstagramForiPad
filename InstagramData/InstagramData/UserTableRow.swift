//
//  UserTableRow.swift
//  InstagramData
//
//  Created by Ben Davis on 04/01/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import RealmSwift

class UserTableRow: Object {
    dynamic var id: String = ""
    
    dynamic var profilePictureURL: String = ""
    dynamic var fullName: String = ""
    dynamic var username: String = ""
    dynamic var biography: String = ""
    dynamic var externalURL: String?
    
    dynamic var mediaCount: Int = 0
    dynamic var followedByCount: Int = 0
    dynamic var followsCount: Int = 0

    dynamic var followedByViewer = false
    dynamic var followsViewer = false

    override static func primaryKey() -> String? {
        return "id"
    }
}
extension UserTableRow {
    
    convenience init(_ user: User) {
        self.init()
        self.id = user.id
        self.profilePictureURL = user.profilePictureURL.absoluteString
        self.fullName = user.fullName
        self.username = user.username
        self.biography = user.biography
        self.externalURL = user.externalURL?.absoluteString
        self.mediaCount = user.mediaCount
        self.followsCount = user.followsCount
        self.followedByCount = user.followedByCount
        self.followedByViewer = user.followedByViewer
        self.followsViewer = user.followsViewer
    }
}

extension User {
    
    init(_ userTableRow: UserTableRow) {
        self.id = userTableRow.id
        self.profilePictureURL = URL(string: userTableRow.profilePictureURL)!
        self.fullName = userTableRow.fullName
        self.username = userTableRow.username
        self.biography = userTableRow.biography
        if let externalURLString = userTableRow.externalURL {
            self.externalURL = URL(string: externalURLString)!
        } else {
            self.externalURL = nil
        }
        self.mediaCount = userTableRow.mediaCount
        self.followsCount = userTableRow.followsCount
        self.followedByCount = userTableRow.followedByCount
        self.followedByViewer = userTableRow.followedByViewer
        self.followsViewer = userTableRow.followsViewer
    }
}

