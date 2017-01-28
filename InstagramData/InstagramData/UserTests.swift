//
//  UserTests.swift
//  InstagramData
//
//  Created by Ben Davis on 28/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import XCTest
import SwiftToolbox
@testable import InstagramData

class UserTests: XCTestCase {
    
    let rawJson: [String:Any] = UserTests.getUserObject()
    
    private class func getUserObject() -> [String:Any] {
        let bundle = Bundle(for: self)
        let filePath = bundle.bundlePath + "/User.json"
        let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
        return try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
    }
    
    func testParsingUser() {
        let user = User(jsonDictionary: rawJson)
        XCTAssertEqual(user.id, "200122996")
        
        XCTAssertEqual(user.profilePictureURL, URL(string: "https://scontent-lhr3-1.cdninstagram.com/t51.2885-19/s150x150/12317796_454000608132252_715718301_a.jpg"))
        XCTAssertEqual(user.fullName, "Ben Davis")
        XCTAssertEqual(user.username, "imben123")
        XCTAssertEqual(user.biography, nil)
        XCTAssertEqual(user.externalURL, nil)
        XCTAssertEqual(user.media!.count, 1)
        XCTAssertEqual(user.totalNumberOfMediaItems!, 1)
    }
}
