//
//  MediaListDataStore.swift
//  InstagramData
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
import RealmSwift

// TODO: Needs tests

class MediaListDataStore {
    
    private let backgroundQueue = DispatchQueue(label: "uk.co.bendavisapps.MediaListDataStore", qos: .background)
    
    init() {
        backgroundQueue.async {
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll()
            }
        }
    }
    
    func saveMediaList(_ listItems: [MediaListItem], with name: String) {
        
        backgroundQueue.async {
            
            let realm = try! Realm()
            
            // TODO: Handle error
            try! realm.write {
                realm.delete(realm.objects(MediaListTableRow.self).filter("name = '\(name)'"))
                realm.add(MediaListTableRow(name, listItems: listItems))
            }
        }
    }
    
    func getMediaList(with name: String, completion: @escaping (_ listItems: [MediaListItem]?) -> Void) {
        
        backgroundQueue.async {
            let realm = try! Realm()
            let mediaItemRows = realm.objects(MediaListTableRow.self).filter("name = '\(name)'").first
            completion(mediaItemRows?.allListItems())
        }
    }
}
