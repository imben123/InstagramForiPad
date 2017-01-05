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
    dynamic var biography: String?
    dynamic var externalURL: String?
    
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
        self.media = nil
        self.totalNumberOfMediaItems = nil
    }
}

