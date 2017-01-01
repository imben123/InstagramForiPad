//
//  MediaList.swift
//  InstagramData
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation

public struct MediaListItem: Equatable {
    public let id: String?
    public let isGap: Bool
    public let gapCursor: String?
    
    public static func ==(_ lhs: MediaListItem, rhs: MediaListItem) -> Bool {
        return (lhs.id == rhs.id && lhs.isGap == rhs.isGap && lhs.gapCursor == rhs.gapCursor)
    }
    
    init(id: String) {
        self.id = id
        self.isGap = false
        self.gapCursor = nil
    }
    
    init(gapCursor: String) {
        self.id = nil
        self.isGap = true
        self.gapCursor = gapCursor
    }
}

class MediaList {
    
    private let name: String
    private let lockQueue = DispatchQueue(label: "uk.co.bendavisapp.MediaListQueue")
    private let mediaDataStore: MediaDataStore
    private let listDataStore: MediaListDataStore
    
    var listItems: [MediaListItem] {
        return privateListItems
    }
    
    var firstGapCursor: String? {
        return listItems.filter({ $0.isGap }).first?.gapCursor
    }
    
    private var privateListItemsBeforeFirstGap: [MediaListItem] = []
    var listItemsBeforeFirstGap: [MediaListItem] {
        return privateListItemsBeforeFirstGap
    }
    
    private var privateMediaIDsBeforeFirstGap: [String] = []
    var mediaIDsBeforeFirstGap: [String] {
        return privateMediaIDsBeforeFirstGap
    }
    
    private var privateMediaCount: Int = 0
    var mediaCount: Int {
        return privateMediaCount
    }
    
    private var privateListItemsValue: [MediaListItem] = []
    private var privateListItems: [MediaListItem] {
        set {
            privateListItemsValue = newValue
            privateListItemsBeforeFirstGap = calculatelistItemsBeforeFirstGap()
            privateMediaIDsBeforeFirstGap = privateListItemsBeforeFirstGap.map({ $0.id! })
            privateMediaCount = calculateMediaCount()
        }
        get {
            return privateListItemsValue
        }
    }
    
    private func calculatelistItemsBeforeFirstGap() -> [MediaListItem] {
        guard let firstGap = listItems.filter({ $0.isGap }).first else {
            return []
        }
        let gapIndex = listItems.index(of: firstGap)!
        return Array(listItems[0..<gapIndex])
    }
    
    private func calculateMediaCount() -> Int {
        guard let firstGap = listItems.filter({ $0.isGap }).first else {
            return 0
        }
        return privateListItems.index(of: firstGap)!
    }
    
    init(name: String, mediaDataStore: MediaDataStore, listDataStore: MediaListDataStore) {
        self.name = name
        self.mediaDataStore = mediaDataStore
        self.listDataStore = listDataStore
        unarchiveMedia()
    }
    
    private func unarchiveMedia() {
        listDataStore.getMediaList(with: name) { [weak self] listItems in
            if let listItems = listItems {
                self?.privateListItems = listItems
            }
        }
    }
    
    func mediaItem(for id: String, completion: @escaping (MediaItem?)->Void) {
        mediaDataStore.loadMediaItem(with: id, completion: completion)
    }
    
    func mediaItems(with ids: [String], completion: @escaping ([MediaItem])->Void) {
        mediaDataStore.loadMediaItems(with: ids, completion: completion)
    }
    
    func appendMoreMedia(_ newMedia: [MediaItem], from startCursor: String, to newEndCursor: String) {
        lockQueue.sync() {
            
            guard let gapIndex = privateListItems.index(where: { $0.isGap && $0.gapCursor == startCursor }) else {
                return
            }
            
            let newerItems = privateListItems[0..<gapIndex]
            let olderItems = privateListItems[gapIndex+1..<privateListItems.count]

            let listItemsToAdd: [MediaListItem]
            if let firstOlderItem = olderItems.first,
                let indexOfOverlap = newMedia.index(where: { $0.id == firstOlderItem.id }) {
                listItemsToAdd = newMedia[0..<indexOfOverlap].map(createMediaListItem)
            } else {
                listItemsToAdd = newMedia.map(createMediaListItem) + [MediaListItem(gapCursor: newEndCursor)]
            }

            privateListItems = newerItems + listItemsToAdd + olderItems
            
            mediaDataStore.archiveMedia(newMedia)
            listDataStore.saveMediaList(privateListItems, with: name)
        }
    }
    
    private func createMediaListItem(from mediaItem: MediaItem) -> MediaListItem {
        return MediaListItem(id: mediaItem.id)
    }
    
    func addNewMedia(_ newMedia: [MediaItem], with newEndCursor: String) {
        lockQueue.sync() {
            
            guard let currentHead = privateListItems.first else {
                privateListItems = newMedia.map(createMediaListItem) + [ MediaListItem(gapCursor: newEndCursor) ]
                mediaDataStore.archiveMedia(newMedia)
                listDataStore.saveMediaList(privateListItems, with: name)
                return
            }
            
            var foundMatch = false
            var result: [MediaListItem] = []
            for mediaItem in newMedia {
                if mediaItem.id == currentHead.id {
                    foundMatch = true
                    break
                }
                result.append(createMediaListItem(from: mediaItem))
            }
            
            if !foundMatch {
                result.append(MediaListItem(gapCursor: newEndCursor))
            }
            result.append(contentsOf: listItems)

            privateListItems = result
            
            mediaDataStore.archiveMedia(newMedia)
            listDataStore.saveMediaList(privateListItems, with: name)
        }
    }
}
