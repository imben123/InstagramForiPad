//
//  MediaDataStore.swift
//  InstagramData
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
import RealmSwift

// TODO: Needs tests

class MediaDataStore {
    
    private let mediaOrigin: String
    
    private let backgroundQueue = DispatchQueue(label: "uk.co.bendavisapps.MediaDataStore", qos: .background)
    
    init(mediaOrigin: String) {
        self.mediaOrigin = mediaOrigin
        backgroundQueue.async {
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll()
            }
        }
    }
    
    func archiveMedia(_ media: [MediaItem]) {
        
        backgroundQueue.async {
            
            let mediaOrigin = self.mediaOrigin
            let realm = try! Realm()
            
            realm.beginWrite()
            
            for mediaItem in media {
                let mediaItemTableRow = MediaItemTableRow(mediaItem, mediaOrigin: "\(mediaOrigin)")
                realm.add(mediaItemTableRow)
            
            }
            
            try? realm.commitWrite()
        }
        
    }
    
    func unarchiveMedia(_ completion: @escaping (_ media: [MediaItem]?) -> Void) {
        
        backgroundQueue.async {
            
            let mediaOrigin = self.mediaOrigin
            let realm = try! Realm()
            
            let mediaItemRows = realm.objects(MediaItemTableRow.self)
                .filter("mediaOrigin = '\(mediaOrigin)'")
            
            var media: [MediaItem] = []
            for mediaItemRow in mediaItemRows {
                media.append(MediaItem(mediaItemRow))
            }
            
            completion(media)
        }
    }
    
}
