//
//  MediaItemCommentTableRow.swift
//  InstagramData
//
//  Created by Ben Davis on 02/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import RealmSwift

class MediaItemCommentTableRow: Object {
    
    dynamic var id: String = ""
    dynamic var text: String = ""
    dynamic var userId: String = ""
    dynamic var userName: String = ""
    dynamic var profilePicture: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }

}

extension MediaItemCommentTableRow {
    
    convenience init(_ mediaItem: MediaItemComment) {
        self.init()
        
        self.id = mediaItem.id
        self.text = mediaItem.text
        self.userId = mediaItem.text
        self.userName = mediaItem.userName
        self.profilePicture = mediaItem.profilePicture.absoluteString
    }
}

extension MediaItemComment {
    
    init(_ mediaItemTableRow: MediaItemCommentTableRow) {
        self.id = mediaItemTableRow.id
        self.text = mediaItemTableRow.text
        self.userId = mediaItemTableRow.userId
        self.userName = mediaItemTableRow.userName
        self.profilePicture = URL(string: mediaItemTableRow.profilePicture)!
    }
}
