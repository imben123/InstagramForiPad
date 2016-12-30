//
//  SwiftyJSONDateTests.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import InstagramData

class SwiftyJSONDateTests: XCTestCase {

    let timestamp: Int = 1483097579 // 12/30/2016 @ 11:32am (UTC)
    let date = Date(timeIntervalSince1970: TimeInterval(1483097579))
    
    func testParseDateTimestampFromInteger() {
        let exampleJSON = [ "timestamp": timestamp ]
        let json = JSON(exampleJSON)
        let result = json["timestamp"].dateValue
        XCTAssertEqual(result, date)
    }
    
    func testParseDateTimestampOptionalFromInteger() {
        let exampleJSON = [ "timestamp": timestamp ]
        let json = JSON(exampleJSON)
        let result = json["timestamp"].date
        XCTAssertEqual(result!, date)
    }
    
    func testParseMissingDate() {
        let exampleJSON = [ "timestamp": timestamp ]
        let json = JSON(exampleJSON)
        let result = json["wrongKey"].date
        XCTAssertNil(result)
    }
    
    func testParseNullDate() {
        let exampleJSON = [ "timestamp": NSNull() ]
        let json = JSON(exampleJSON)
        let result = json["timestamp"].date
        XCTAssertNil(result)
    }
    
    func testSetDate() {
        var json = JSON([:])
        json["timestamp"].dateValue = date
        let result = json.rawString()!
        XCTAssertEqual(result, "{\n  \"timestamp\" : 1483097579\n}")
    }
    
    func testSetOptionalDate() {
        var json = JSON([:])
        let optionalDate: Date? = date
        json["timestamp"].date = optionalDate
        let result = json.rawString()!
        XCTAssertEqual(result, "{\n  \"timestamp\" : 1483097579\n}")
    }
    
    func testSetNilDate() {
        var json = JSON([:])
        json["timestamp"].date = nil
        let result = json.rawString()!
        XCTAssertEqual(result, "{\n  \"timestamp\" : null\n}")
    }
}
