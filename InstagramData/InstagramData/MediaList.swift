//
//  MediaList.swift
//  InstagramData
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation

class MediaList: GappedList {
    
    private let mediaDataStore: MediaDataStore

    init(name: String, mediaDataStore: MediaDataStore, listDataStore: GappedListDataStore) {
        self.mediaDataStore = mediaDataStore
        super.init(name: name, listDataStore: listDataStore)
    }
    
    func mediaItem(for id: String, completion: @escaping (MediaItem?)->Void) {
        mediaDataStore.loadMediaItem(with: id, completion: completion)
    }
    
    func mediaItems(with ids: [String], completion: @escaping ([MediaItem])->Void) {
        mediaDataStore.loadMediaItems(with: ids, completion: completion)
    }
    
    func appendMoreMedia(_ newMedia: [MediaItem], from startCursor: String, to newEndCursor: String?) {
        if indexOfGap(withCursor: startCursor) != nil {
            mediaDataStore.archiveMedia(newMedia)
        }
        super.appendMoreItems(newMedia.map() { $0.id }, from: startCursor, to: newEndCursor)
    }
    
    func addNewMedia(_ newMedia: [MediaItem], with newEndCursor: String?) {
        
        if newEndCursor == nil && itemCount > 0 {
            print("Latest media had no end cursor. Cannot link up with previous cached media so deleting all.")
            mediaDataStore.deleteAllMedia()
        }
        
        mediaDataStore.archiveMedia(newMedia)
        
        super.addNewItems(newMedia.map() { $0.id }, with: newEndCursor)
    }
}
