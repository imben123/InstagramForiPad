//
//  SwiftyJSONURLTests.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import InstagramData

class SwiftyJSONURLTests: XCTestCase {
    
    let url: URL? = URL(string: "http://www.google.com?foo=bar%20baz")
    let urlString = "http://www.google.com?foo=bar%20baz"
    
    func testParseSizeOptionalDictionary() {
        let exampleJSON = [ "url": urlString ]
        let json = JSON(exampleJSON)
        let result = json["url"].URLWithoutEscaping
        XCTAssertEqual(result!, url!)
    }
    
    func testParseMissingSize() {
        let exampleJSON = [ "url": urlString ]
        let json = JSON(exampleJSON)
        let result = json["wrongKey"].URLWithoutEscaping
        XCTAssertNil(result)
    }
    
    func testParseNullSize() {
        let exampleJSON = [ "url": NSNull() ]
        let json = JSON(exampleJSON)
        let result = json["url"].URLWithoutEscaping
        XCTAssertNil(result)
    }
    
    func testSetOptionalSize() {
        var json = JSON([:])
        json["url"].URLWithoutEscaping = url
        let result = json.rawString()!
        // JSONSerialization class escapes the slashes in the string - not sure whether this is ok?
        XCTAssertEqual(result, "{\n  \"url\" : \"http:\\/\\/www.google.com?foo=bar%20baz\"\n}")
    }
    
    func testSetNilSize() {
        var json = JSON([:])
        json["url"].URLWithoutEscaping = nil
        let result = json.rawString()!
        XCTAssertEqual(result, "{\n  \"url\" : null\n}")
    }
    
}
