//
//  MockGappedListDataStore.swift
//  InstagramData
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
@testable import InstagramData

class MockGappedListDataStore: GappedListDataStore {
    
    var savedItemList: (listItems: [GappedListItem], name: String)? = nil
    
    override func saveItemList(_ listItems: [GappedListItem], with name: String) {
        savedItemList = (listItems, name)
    }
    
    override func getItemList(with name: String, completion: @escaping (_ listItems: [GappedListItem]?) -> Void) {
        if name == savedItemList?.name {
            completion(savedItemList?.listItems)
        } else {
            completion(nil)
        }
    }
}
