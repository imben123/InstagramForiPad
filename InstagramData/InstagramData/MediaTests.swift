//
//  MediaTests.swift
//  InstagramData
//
//  Created by Ben Davis on 28/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import XCTest
import SwiftToolbox
@testable import InstagramData

class MediaTests: XCTestCase {
    
    let rawMediaItemJson: [String:Any] = MediaTests.getObject(with: "MediaItem.json")
    
    func testParsingMediaItem() {
        let mediaItem = MediaItem(jsonDictionary: rawMediaItemJson)
        
        XCTAssertEqual(mediaItem.id, "1437230250416969754")
        
        XCTAssertEqual(mediaItem.date, Date(timeIntervalSince1970: 1485551218))
        XCTAssertEqual(mediaItem.dimensions, CGSize(width: 1080, height: 1347))

        XCTAssertEqual(mediaItem.owner.id, "186622962")
        XCTAssertEqual(mediaItem.owner.profilePictureURL, URL(string: "https://scontent-lhr3-1.cdninstagram.com/t51.2885-19/s150x150/13561734_210464792681658_976264848_a.jpg")!)
        XCTAssertEqual(mediaItem.owner.fullName, "Lindsey Stirling")
        XCTAssertEqual(mediaItem.owner.username, "lindseystirling")
        XCTAssertEqual(mediaItem.owner.biography, "")
        XCTAssertNil(mediaItem.owner.externalURL)
        XCTAssertEqual(mediaItem.owner.mediaCount, 0)

        XCTAssertEqual(mediaItem.code, "BPyEUxIjJga")
        XCTAssertEqual(mediaItem.isVideo, false)
        
        XCTAssertEqual(mediaItem.thumbnail, URL(string: "https://scontent-lhr3-1.cdninstagram.com/t51.2885-15/s640x640/sh0.08/e35/c0.133.1080.1080/16110609_1619749501666416_8231098677238693888_n.jpg?ig_cache_key=MTQzNzIzMDI1MDQxNjk2OTc1NA%3D%3D.2.c"))
        XCTAssertEqual(mediaItem.display, URL(string: "https://scontent-lhr3-1.cdninstagram.com/t51.2885-15/e35/16110609_1619749501666416_8231098677238693888_n.jpg?ig_cache_key=MTQzNzIzMDI1MDQxNjk2OTc1NA%3D%3D.2"))
        
        XCTAssertEqual(mediaItem.commentsDisabled, false)
        XCTAssertEqual(mediaItem.commentsCount, 618)
        XCTAssertEqual(mediaItem.likesCount, 64679)
    }
}
