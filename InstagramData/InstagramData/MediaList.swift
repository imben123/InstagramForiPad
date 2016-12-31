//
//  MediaList.swift
//  InstagramData
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation

struct MediaListItem: Equatable {
    let id: String?
    let isGap: Bool
    let gapCursor: String?
    
    static func ==(_ lhs: MediaListItem, rhs: MediaListItem) -> Bool {
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
    
    private var privateListItems: [MediaListItem] = []
    var listItems: [MediaListItem] {
        return privateListItems
    }

    var firstGapCursor: String? {
        return listItems.filter({ $0.isGap }).first?.gapCursor
    }
    
    private var privateMedia: [MediaItem] = []
    var media: [MediaItem] {
        guard let firstGap = listItems.filter({ $0.isGap }).first else {
            return []
        }
        let gapIndex = privateListItems.index(of: firstGap)!
        return privateListItems[0..<gapIndex].map({ mediaItem(for: $0.id!)! })
    }
    
    private func mediaItem(for id: String) -> MediaItem? {
        for mediaItem in privateMedia {
            if mediaItem.id == id {
                return mediaItem
            }
        }
        return nil
    }
    
    init(name: String, mediaDataStore: MediaDataStore, listDataStore: MediaListDataStore) {
        self.name = name
        self.mediaDataStore = mediaDataStore
        self.listDataStore = listDataStore
        unarchiveMedia()
    }
    
    func unarchiveMedia() {
        mediaDataStore.unarchiveMedia { [weak self] media in
            if let media = media {
                self?.privateMedia = media
            }
        }
        listDataStore.getMediaList(with: name) { [weak self] listItems in
            if let listItems = listItems {
                self?.privateListItems = listItems
            }
        }
    }
    
    func appendMoreMedia(_ newMedia: [MediaItem], from startCursor: String, to newEndCursor: String) {
        lockQueue.sync() {
            
            privateMedia.append(contentsOf: newMedia)

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
            
            mediaDataStore.archiveMedia(privateMedia)
            listDataStore.saveMediaList(privateListItems, with: name)
        }
    }
    
    func createMediaListItem(from mediaItem: MediaItem) -> MediaListItem {
        return MediaListItem(id: mediaItem.id)
    }
    
    func addNewMedia(_ newMedia: [MediaItem], with newEndCursor: String) {
        lockQueue.sync() {
            
            privateMedia.append(contentsOf: newMedia)
            
            guard let currentHead = media.first else {
                privateListItems = newMedia.map(createMediaListItem) + [ MediaListItem(gapCursor: newEndCursor) ]
                mediaDataStore.archiveMedia(privateMedia)
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
            
            mediaDataStore.archiveMedia(privateMedia)
            listDataStore.saveMediaList(privateListItems, with: name)
        }
    }
}
