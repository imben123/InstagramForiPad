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
    let replies = List<MediaItemCommentTableRow>()
    
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
        for reply in mediaItem.replies {
            replies.append(MediaItemCommentTableRow(reply))
        }
    }
}

extension MediaItemComment {
    
    init(_ mediaItemTableRow: MediaItemCommentTableRow) {
        self.id = mediaItemTableRow.id
        self.text = mediaItemTableRow.text
        self.user = User(mediaItemTableRow.user!)
        self.replies = mediaItemTableRow.replies.map({ .init($0) })
    }
}
