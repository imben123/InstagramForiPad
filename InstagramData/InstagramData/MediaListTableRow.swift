//
//  MediaListTableRow.swift
//  InstagramData
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
import RealmSwift

class MediaListTableRow: Object {
    dynamic var name: String = ""
    let items = List<MediaListItemTableRow>()
}

extension MediaListTableRow {
    convenience init(_ name: String, listItems: [MediaListItem]) {
        self.init()
        self.name = name
        
        for item in listItems {
            items.append(MediaListItemTableRow(item))
        }
    }
    
    func allListItems() -> [MediaListItem] {
        var result: [MediaListItem] = []
        for rowItem in items {
            result.append(MediaListItem(rowItem))
        }
        return result
    }
}

class MediaListItemTableRow: Object {
    dynamic var id: String?
    dynamic var isGap: Bool = false
    dynamic var gapCursor: String?
}

extension MediaListItemTableRow {
    convenience init(_ listItem: MediaListItem) {
        self.init()
        self.id = listItem.id
        self.isGap = listItem.isGap
        self.gapCursor = listItem.gapCursor
    }
}

extension MediaListItem {
    init(_ mediaListItemTableRow: MediaListItemTableRow) {
        id = mediaListItemTableRow.id
        isGap = mediaListItemTableRow.isGap
        gapCursor = mediaListItemTableRow.gapCursor
    }
}
