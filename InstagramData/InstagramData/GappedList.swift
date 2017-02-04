//
//  GappedList.swift
//  InstagramData
//
//  Created by Ben Davis on 04/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import Foundation

public struct GappedListItem: Equatable {
    public let id: String?
    public let isGap: Bool
    public let gapCursor: String?
    
    public static func ==(_ lhs: GappedListItem, rhs: GappedListItem) -> Bool {
        return (lhs.id == rhs.id && lhs.isGap == rhs.isGap && lhs.gapCursor == rhs.gapCursor)
    }
    
    init(id: String) {
        self.id = id
        self.isGap = false
        self.gapCursor = nil
    }
    
    init(gapCursor: String?) {
        self.id = nil
        self.isGap = true
        self.gapCursor = gapCursor
    }
}

class GappedList {
    
    private let name: String
    private let lockQueue = DispatchQueue(label: "uk.co.bendavisapp.GappedListQueue")
    private let listDataStore: GappedListDataStore
    
    var listItems: [GappedListItem] {
        return privateListItems
    }
    
    var firstGapCursor: String? {
        return listItems.filter({ $0.isGap && $0.gapCursor != nil }).first?.gapCursor
    }
    
    private var privateListItemsBeforeFirstGap: [GappedListItem] = []
    var listItemsBeforeFirstGap: [GappedListItem] {
        return privateListItemsBeforeFirstGap
    }
    
    private var privateItemIDsBeforeFirstGap: [String] = []
    var itemIDsBeforeFirstGap: [String] {
        return privateItemIDsBeforeFirstGap
    }
    
    private var privateItemCount: Int = 0
    var itemCount: Int {
        return privateItemCount
    }
    
    private var privateListItemsValue: [GappedListItem] = []
    private var privateListItems: [GappedListItem] {
        set {
            privateListItemsValue = newValue
            privateListItemsBeforeFirstGap = calculatelistItemsBeforeFirstGap()
            privateItemIDsBeforeFirstGap = privateListItemsBeforeFirstGap.map({ $0.id! })
            privateItemCount = calculateitemCount()
        }
        get {
            return privateListItemsValue
        }
    }
    
    private func calculatelistItemsBeforeFirstGap() -> [GappedListItem] {
        guard let firstGap = listItems.filter({ $0.isGap }).first else {
            return []
        }
        let gapIndex = listItems.index(of: firstGap)!
        return Array(listItems[0..<gapIndex])
    }
    
    private func calculateitemCount() -> Int {
        guard let firstGap = listItems.filter({ $0.isGap }).first else {
            return 0
        }
        return privateListItems.index(of: firstGap)!
    }
    
    init(name: String, listDataStore: GappedListDataStore) {
        self.name = name
        self.listDataStore = listDataStore
        unarchiveMedia()
    }
    
    private func unarchiveMedia() {
        let semaphore = DispatchSemaphore(value: 0)
        listDataStore.getItemList(with: name) { [weak self] listItems in
            if let listItems = listItems {
                self?.privateListItems = listItems
            }
            semaphore.signal()
        }
        semaphore.wait()
    }
    
    func indexOfGap(withCursor gapCursor: String) -> Int? {
        return privateListItems.index(where: { $0.isGap && $0.gapCursor == gapCursor })
    }
    
    func appendMoreItems(_ itemIds: [String], from startCursor: String, to newEndCursor: String?) {
        lockQueue.sync() {
            
            guard let gapIndex = indexOfGap(withCursor: startCursor) else {
                return
            }
            
            let newerItems = privateListItems[0..<gapIndex]
            let olderItems = privateListItems[gapIndex+1..<privateListItems.count]
            
            let listItemsToAdd: [GappedListItem]
            if let firstOlderItem = olderItems.first,
                let indexOfOverlap = itemIds.index(of: firstOlderItem.id!) {
                listItemsToAdd = itemIds[0..<indexOfOverlap].map(createGappedListItem)
            } else {
                listItemsToAdd = itemIds.map(createGappedListItem) + [GappedListItem(gapCursor: newEndCursor)]
            }
            
            privateListItems = newerItems + listItemsToAdd + olderItems
            
            listDataStore.saveItemList(privateListItems, with: name)
        }
    }
    
    private func createGappedListItem(from itemId: String) -> GappedListItem {
        return GappedListItem(id: itemId)
    }
    
    func addNewItems(_ itemIds: [String], with newEndCursor: String?) {
        lockQueue.sync() {
            
            if newEndCursor == nil {
                privateListItems = []
                print("Latest media had no end cursor. Cannot link up with previous cached media so deleting all.")
            }
            
            guard let currentHead = privateListItems.first else {
                privateListItems = itemIds.map(createGappedListItem) + [ GappedListItem(gapCursor: newEndCursor) ]
                listDataStore.saveItemList(privateListItems, with: name)
                return
            }
            
            var foundMatch = false
            var result: [GappedListItem] = []
            for itemId in itemIds {
                if itemId == currentHead.id {
                    foundMatch = true
                    break
                }
                result.append(createGappedListItem(from: itemId))
            }
            
            if !foundMatch {
                result.append(GappedListItem(gapCursor: newEndCursor))
            }
            result.append(contentsOf: listItems)
            
            privateListItems = result
            
            listDataStore.saveItemList(privateListItems, with: name)
        }
    }
}
