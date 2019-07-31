//
//  MediaItemCommentTableRow.swift
//  InstagramData
//
//  Created by Ben Davis on 02/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import RealmSwift

public class MediaItemCommentTableRow: Object {
    
    @objc dynamic var id: String = ""
    @objc dynamic var text: String = ""
    @objc dynamic var user: UserTableRow?
    
    public override static func primaryKey() -> String? {
        return "id"
    }
}

extension MediaItemCommentTableRow {
    
    convenience init(_ mediaItem: MediaItemComment) {
        self.init()
        
        self.id = mediaItem.id
        self.text = mediaItem.text
        self.user = UserTableRow(mediaItem.user)
    }
}

extension MediaItemComment {
    
    init(_ mediaItemTableRow: MediaItemCommentTableRow) {
        self.id = mediaItemTableRow.id
        self.text = mediaItemTableRow.text
        self.user = User(mediaItemTableRow.user!)
    }
}
