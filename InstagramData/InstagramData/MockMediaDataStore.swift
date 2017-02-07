//
//  MockMediaDataStore.swift
//  InstagramData
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
@testable import InstagramData

class MockMediaDataStore: MediaDataStore {
    
    var archivedMediaList: [MediaItem]? = nil
    
    var mediaItemToLoad: MediaItem? = nil
    var loadMediaItemIDParameter: String? = nil
    
    var mediaItemsToLoad: [MediaItem] = []
    var loadMediaItemsIDsParameter: [String]? = nil
    
    override func archiveMedia(_ media: [MediaItem], completion: (() -> Void)?) {
        archivedMediaList = media
    }
    
    override func loadMediaItem(with id: String, completion: @escaping (_ media: MediaItem?) -> Void) {
        loadMediaItemIDParameter = id
        completion(mediaItemToLoad)
    }
    
    override func loadMediaItems(with ids: [String], completion: @escaping ([MediaItem]) -> Void) {
        loadMediaItemsIDsParameter = ids
        completion(mediaItemsToLoad)
    }
    
    override func unarchiveMedia(_ completion: @escaping (_ media: [MediaItem]) -> Void) {
        completion(archivedMediaList ?? [])
    }
    
    override func deleteAllMedia() {
        
    }
}
