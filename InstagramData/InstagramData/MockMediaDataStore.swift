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
    
    var archivedMediaList: (media: [MediaItem], endCursor: String)? = nil
    var testUnarchiveMediaList: (media: [MediaItem], endCursor: String)? = nil
    
    override var maximumNumberOfStoredRows: Int {
        get {
            return 0
        }
        set {
            
        }
    }
    
    override func archiveCurrentMedia(_ media: [MediaItem], newEndCursor: String) {
        archivedMediaList = (media, newEndCursor)
    }
    
    override func unarchiveCurrentMedia(_ completion: @escaping ((media: [MediaItem], endCursor: String)?) -> Void) {
        completion((testUnarchiveMediaList != nil) ? testUnarchiveMediaList : archivedMediaList)
    }
}
