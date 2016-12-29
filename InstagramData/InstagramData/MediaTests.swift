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
    
    private class func getObject(with fileName: String) -> [String:Any] {
        let bundle = Bundle(for: self)
        let filePath = bundle.bundlePath + "/" + fileName
        let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
        return try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
    }
    
    func testParsingMediaItem() {
        let mediaItem = MediaItem(jsonDictionary: rawMediaItemJson)
        
        XCTAssertEqual(mediaItem.id, "1366243591862082687")
        
        XCTAssertEqual(mediaItem.date, Date(timeIntervalSince1970: 1477088949))
        XCTAssertEqual(mediaItem.dimensions, CGSize(width: 1080, height: 1080))
        XCTAssertEqual(mediaItem.ownerId, "200122996")
        XCTAssertEqual(mediaItem.code, "BL1307hl9x_")
        XCTAssertEqual(mediaItem.isVideo, false)
        
        XCTAssertEqual(mediaItem.thumbnail, URL(string: "https://scontent-lhr3-1.cdninstagram.com/t51.2885-15/s640x640/sh0.08/e35/14730568_1798998070347864_3046428708303798272_n.jpg?ig_cache_key=MTM2NjI0MzU5MTg2MjA4MjY4Nw%3D%3D.2"))
        XCTAssertEqual(mediaItem.display, URL(string: "https://scontent-lhr3-1.cdninstagram.com/t51.2885-15/e35/14730568_1798998070347864_3046428708303798272_n.jpg?ig_cache_key=MTM2NjI0MzU5MTg2MjA4MjY4Nw%3D%3D.2"))
        
        XCTAssertEqual(mediaItem.commentsDisabled, false)
        XCTAssertEqual(mediaItem.commentsCount, 0)
        XCTAssertEqual(mediaItem.likesCount, 18)
    }
}
