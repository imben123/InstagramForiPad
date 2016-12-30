//
//  SwiftyJSONDimensionsTests.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import InstagramData

class SwiftyJSONDimensionsTests: XCTestCase {
    
    let size: CGSize = CGSize(width: 123, height: 456)
    let sizeDictionary = [ "width": 123, "height": 456 ]
    
    func testParseSizeFromDictionary() {
        let exampleJSON = [ "size": sizeDictionary ]
        let json = JSON(exampleJSON)
        let result = json["size"].sizeValue
        XCTAssertEqual(result, size)
    }
    
    func testParseSizeOptionalDictionary() {
        let exampleJSON = [ "size": sizeDictionary ]
        let json = JSON(exampleJSON)
        let result = json["size"].size
        XCTAssertEqual(result!, size)
    }
    
    func testParseMissingSize() {
        let exampleJSON = [ "size": sizeDictionary ]
        let json = JSON(exampleJSON)
        let result = json["wrongKey"].size
        XCTAssertNil(result)
    }
    
    func testParseNullSize() {
        let exampleJSON = [ "size": NSNull() ]
        let json = JSON(exampleJSON)
        let result = json["size"].size
        XCTAssertNil(result)
    }
    
    func testSetSize() {
        var json = JSON([:])
        json["size"].sizeValue = size
        let result = json.rawString()!
        checkJSONStringAgainstExpected(result)
    }
    
    func testSetOptionalSize() {
        var json = JSON([:])
        let optionalSize: CGSize? = size
        json["size"].size = optionalSize
        let result = json.rawString()!
        checkJSONStringAgainstExpected(result)
    }
    
    func checkJSONStringAgainstExpected(_ result: String) {
        if result != "{\n  \"size\" : {\n    \"width\" : 123,\n    \"height\" : 456\n  }\n}" &&
            result != "{\n  \"size\" : {\n    \"height\" : 456,\n    \"width\" : 123\n  }\n}" {
            XCTFail("\(result) is not equal to expected")
        }
    }
    
    func testSetNilSize() {
        var json = JSON([:])
        json["size"].size = nil
        let result = json.rawString()!
        XCTAssertEqual(result, "{\n  \"size\" : null\n}")
    }
}
