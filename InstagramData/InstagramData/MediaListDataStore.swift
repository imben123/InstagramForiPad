//
//  MediaListDataStore.swift
//  InstagramData
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
import RealmSwift

class MediaListDataStore {
    
    private let mediaOrigin: String
    var maximumNumberOfStoredRows: Int = Int.max // Currently no limit
    
    private let backgroundQueue = DispatchQueue(label: "uk.co.bendavisapps.MediaListDataStore", qos: .background)
    
    init(mediaOrigin: String) {
        self.mediaOrigin = mediaOrigin
    }
    
    func archiveCurrentMediaList(_ media: [MediaItem], newEndCursor: String) {
        
        backgroundQueue.async {
            
            let mediaOrigin = self.mediaOrigin
            let realm = try! Realm()
            
            realm.beginWrite()
            
            // Delete previous feed info
            let mediaItemRows = realm.objects(MediaItemTableRow.self).filter("mediaOrigin = '\(mediaOrigin)'")
            for mediaItemRow in mediaItemRows {
                realm.delete(mediaItemRow)
            }
            
            // Add new feed info
            var i = 0
            for mediaItem in media {
                let mediaItemTableRow = MediaItemTableRow(mediaItem, mediaOrigin: "\(mediaOrigin)", ordering: i)
                realm.add(mediaItemTableRow)
                i += 1
                if i == self.maximumNumberOfStoredRows {
                    break
                }
            }
            
            // Update end cursor
            realm.delete(realm.objects(MediaListDataStoreEndCursor.self).filter("mediaOrigin = '\(mediaOrigin)'"))
            realm.add(MediaListDataStoreEndCursor(value: ["value": newEndCursor, "mediaOrigin": mediaOrigin]))
            
            try? realm.commitWrite()
        }
        
    }
    
    func unarchiveCurrentMediaList(_ completion: @escaping ((media: [MediaItem], endCursor: String)?) -> Void) {
        
        backgroundQueue.async {
            
            let mediaOrigin = self.mediaOrigin
            let realm = try! Realm()
            
            guard let endCursor = realm.objects(MediaListDataStoreEndCursor.self)
                .filter("mediaOrigin = '\(mediaOrigin)'").first
                else {
                    return completion(nil)
            }
            
            let mediaItemRows = realm.objects(MediaItemTableRow.self)
                .filter("mediaOrigin = '\(mediaOrigin)'")
                .sorted(byProperty: "ordering")
            
            var media: [MediaItem] = []
            for mediaItemRow in mediaItemRows {
                media.append(MediaItem(mediaItemRow))
            }
            
            completion((media: media, endCursor: endCursor.value))
        }
    }
    
}
