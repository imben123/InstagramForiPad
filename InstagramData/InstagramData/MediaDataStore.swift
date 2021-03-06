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

protocol MediaDataStoreObserver: class {
    func mediaDataStore(_ sender: MediaDataStore, didArchiveNewMedia newMedia: [MediaItem])
}

class MediaDataStore {
    
    weak var observer: MediaDataStoreObserver?
    
    private let backgroundQueue = DispatchQueue(label: "uk.co.bendavisapps.MediaDataStore", qos: .background)
    
    func archiveMedia(_ media: [MediaItem], completion: (()->Void)? = nil) {
        
        backgroundQueue.async {
            
            let realm = try! Realm()
            
            realm.beginWrite()
            
            for mediaItem in media {
                let mediaItemTableRow = MediaItemTableRow(mediaItem)
                realm.add(mediaItemTableRow, update: .all)
            }
            
            try? realm.commitWrite()
            
            DispatchQueue.main.async { [weak self] in
                completion?()
                self?.observer?.mediaDataStore(self!, didArchiveNewMedia: media)
            }
        }
        
    }
    
    func loadMediaItem(with id: String, completion: @escaping (_ media: MediaItem?) -> Void) {
        backgroundQueue.async {
            let realm = try! Realm()
            let mediaItemRow = realm.objects(MediaItemTableRow.self).filter("id = '\(id)'").first
            if let mediaItemRow = mediaItemRow {
                completion(MediaItem(mediaItemRow))
            } else {
                completion(nil)
            }
        }
    }
    
    func loadMediaItems(with ids: [String], completion: @escaping (_ media: [MediaItem]) -> Void) {
        backgroundQueue.async {
            let realm = try! Realm()
            var first = true
            let idsString = ids.reduce("", { (result, id) -> String in
                if first {
                    first = false
                    return result + "'\(id)'"
                } else {
                    return result + ",'\(id)'"
                }
            })
            let mediaItemRows = realm.objects(MediaItemTableRow.self).filter("id IN {\(idsString)}")
            let result: [MediaItem] = mediaItemRows.map({ MediaItem($0) })
            completion(result)
        }
    }
    
    func unarchiveMedia(_ completion: @escaping (_ media: [MediaItem]) -> Void) {
        
        backgroundQueue.async {
            
            let realm = try! Realm()
            
            let mediaItemRows = realm.objects(MediaItemTableRow.self)
            
            var media: [MediaItem] = []
            for mediaItemRow in mediaItemRows {
                media.append(MediaItem(mediaItemRow))
            }
            
            completion(media)
        }
    }
    
    func deleteAllMedia() {
        backgroundQueue.sync {
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(MediaItemTableRow.self))
            }
        }
    }
    
}
