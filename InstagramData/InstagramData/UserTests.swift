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
    
    class func getUserObject() -> [String:Any] {
        let bundle = Bundle(for: self)
        let filePath = bundle.bundlePath + "/User.json"
        let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
        return try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
    }
    
    func testParsingUser() {
        let user = User(jsonDictionary: rawJson)
        XCTAssertEqual(user.id, "1417593507")
        
        XCTAssertEqual(user.profilePictureURL, URL(string: "https://scontent-lhr3-1.cdninstagram.com/t51.2885-19/s150x150/18298380_307218413048910_6040080428977618944_a.jpg"))
        XCTAssertEqual(user.fullName, "Liza D")
        XCTAssertEqual(user.username, "lizadegtiarenko")
        XCTAssertEqual(user.biography, "All the travels🚌")
        XCTAssertEqual(user.externalURL, URL(string:"http://sustain.life/"))
        XCTAssertEqual(user.mediaCount, 507)
    }
}
