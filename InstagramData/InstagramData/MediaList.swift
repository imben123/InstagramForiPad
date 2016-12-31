//
//  MediaList.swift
//  InstagramData
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation


class MediaList {
    
    private let lockQueue = DispatchQueue(label: "uk.co.bendavisapp.MediaListQueue")
    private let dataStore: MediaDataStore
    
    private var privateEndCursor: String? = nil
    var endCursor: String? {
        return privateEndCursor
    }
    
    private var privateMedia: [MediaItem] = []
    var media: [MediaItem] {
        return privateMedia
    }
    
    init(dataStore: MediaDataStore) {
        self.dataStore = dataStore
        unarchive()
    }
    
    func unarchive() {
        dataStore.unarchiveCurrentMedia() { [weak self] in
            if let archive = $0 {
                self?.privateMedia = archive.media
                self?.privateEndCursor = archive.endCursor
            }
        }
    }
    
    func appendMoreMedia(_ newMedia: [MediaItem], from startCursor: String, to newEndCursor: String) {
        lockQueue.sync() {
            if startCursor == endCursor {
                privateMedia.append(contentsOf: newMedia)
                privateEndCursor = newEndCursor
                dataStore.archiveCurrentMedia(media, newEndCursor: newEndCursor)
            }
        }
    }
    
    func addNewMedia(_ newMedia: [MediaItem], with newEndCursor: String) {
        lockQueue.sync() {
            
            guard let currentHead = media.first else {
                privateMedia = newMedia
                privateEndCursor = newEndCursor
                dataStore.archiveCurrentMedia(media, newEndCursor: newEndCursor)
                return
            }
            
            var foundMatch = false
            var result: [MediaItem] = []
            for mediaItem in newMedia {
                if mediaItem.id == currentHead.id {
                    foundMatch = true
                    break
                }
                result.append(mediaItem)
            }
            
            if foundMatch {
                result.append(contentsOf: media)
            } else {
                privateEndCursor = newEndCursor
            }
            privateMedia = result
            
            dataStore.archiveCurrentMedia(media, newEndCursor: newEndCursor)
        }
    }
}
