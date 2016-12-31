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
    
    var archivedMediaList: (media: [MediaItem], endCursor: String)? = nil
    var testUnarchiveMediaList: (media: [MediaItem], endCursor: String)? = nil
    
    override var maximumNumberOfStoredRows: Int {
        get {
            return 0
        }
        set {
            
        }
    }
    
    override func archiveCurrentMediaList(_ media: [MediaItem], newEndCursor: String) {
        archivedMediaList = (media, newEndCursor)
    }
    
    override func unarchiveCurrentMediaList() -> (media: [MediaItem], endCursor: String)? {
        return (testUnarchiveMediaList != nil) ? testUnarchiveMediaList : archivedMediaList
    }
}
