//
//  APIResponseTests.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import XCTest
@testable import InstagramData

class APIResponseTests: XCTestCase {
    
    let exampleResponseCode = 123
    let exampleResponseBody = [ "foo": "bar" ]
    let exampleURLReponse = URLResponse(url: URL(string: "http://www.google.com")!,
                                        mimeType: nil,
                                        expectedContentLength: 123,
                                        textEncodingName: nil)
    
    func testCanCreateResponse() {
        let response = APIResponse(responseCode: exampleResponseCode,
                                   responseBody: exampleResponseBody,
                                   urlResponse: exampleURLReponse)
        XCTAssertEqual(response.responseCode, exampleResponseCode)
        XCTAssertEqual(response.responseBody as! [String:String], exampleResponseBody)
        XCTAssertEqual(response.urlResponse, exampleURLReponse)
    }
    
    func testNoInternetResponse() {
        let response = APIResponse.noInternetResponse
        XCTAssertEqual(response.responseCode, 0)
        XCTAssertNil(response.responseBody)
        XCTAssertNil(response.urlResponse)
    }
    
    func testSuccess() {
        XCTAssertFalse(response(withResponseCode: 199).succeeded)
        XCTAssertTrue(response(withResponseCode: 200).succeeded)
        XCTAssertTrue(response(withResponseCode: 300).succeeded)
        XCTAssertTrue(response(withResponseCode: 399).succeeded)
        XCTAssertFalse(response(withResponseCode: 400).succeeded)
        XCTAssertFalse(response(withResponseCode: 500).succeeded)
    }
    
    func response(withResponseCode code: Int) -> APIResponse {
        return APIResponse(responseCode: code,
                           responseBody: exampleResponseBody,
                           urlResponse: exampleURLReponse)
    }
    
}
