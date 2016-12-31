//
//  MockMediaListDataStore.swift
//  InstagramData
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
@testable import InstagramData

class MockMediaListDataStore: MediaListDataStore {
    
    var savedMediaList: (listItems: [MediaListItem], name: String)? = nil
    
    override func saveMediaList(_ listItems: [MediaListItem], with name: String) {
        savedMediaList = (listItems, name)
    }
    
    override func getMediaList(with name: String, completion: @escaping (_ listItems: [MediaListItem]?) -> Void) {
        if name == savedMediaList?.name {
            completion(savedMediaList?.listItems)
        } else {
            completion(nil)
        }
    }
}
