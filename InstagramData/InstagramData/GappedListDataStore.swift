//
//  GappedListDataStore.swift
//  InstagramData
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
import RealmSwift

// TODO: Needs tests

class GappedListDataStore {
    
    private let backgroundQueue = DispatchQueue(label: "uk.co.bendavisapps.GappedListDataStore", qos: .background)
    
    func saveItemList(_ listItems: [GappedListItem], with name: String) {
        
        backgroundQueue.async {
            
            let realm = try! Realm()
            
            // TODO: Handle error
            try! realm.write {
                realm.delete(realm.objects(GappedListTableRow.self).filter("name = '\(name)'"))
                realm.add(GappedListTableRow(name, listItems: listItems))
            }
        }
    }
    
    func getItemList(with name: String, completion: @escaping (_ listItems: [GappedListItem]?) -> Void) {
        
        backgroundQueue.async {
            let realm = try! Realm()
            let mediaItemRows = realm.objects(GappedListTableRow.self).filter("name = '\(name)'").first
            completion(mediaItemRows?.allListItems())
        }
    }
}
