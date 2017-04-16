//
//  GappedListTableRow.swift
//  InstagramData
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
import RealmSwift

class GappedListTableRow: Object {
    dynamic var name: String = ""
    let items = List<GappedListItemTableRow>()
}

extension GappedListTableRow {
    convenience init(_ name: String, listItems: [GappedListItem]) {
        self.init()
        self.name = name
        
        for item in listItems {
            items.append(GappedListItemTableRow(item))
        }
    }
    
    func allListItems() -> [GappedListItem] {
        var result: [GappedListItem] = []
        for rowItem in items {
            result.append(GappedListItem(rowItem))
        }
        return result
    }
}

class GappedListItemTableRow: Object {
    dynamic var id: String?
    dynamic var isGap: Bool = false
    dynamic var gapCursor: String?
}

extension GappedListItemTableRow {
    convenience init(_ listItem: GappedListItem) {
        self.init()
        self.id = listItem.id
        self.isGap = listItem.isGap
        self.gapCursor = listItem.gapCursor
    }
}

extension GappedListItem {
    init(_ mediaListItemTableRow: GappedListItemTableRow) {
        if mediaListItemTableRow.isGap {
            self = .gap(gapCursor: mediaListItemTableRow.gapCursor)
        } else {
            self = .item(id: mediaListItemTableRow.id!)
        }
    }
}
