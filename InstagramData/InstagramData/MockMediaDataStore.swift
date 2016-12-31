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
    
    override func archiveMedia(_ media: [MediaItem]) {
        archivedMediaList = media
    }
    
    override func unarchiveMedia(_ completion: @escaping (_ media: [MediaItem]?) -> Void) {
        completion(archivedMediaList)
    }
}
