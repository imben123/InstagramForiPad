//
//  APIConnectionRequestBuilderTests.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import XCTest
@testable import InstagramData

class APIConnectionRequestBuilderTests: XCTestCase {
    
    let cookie = HTTPCookie(properties: [
        .name: "foo",
        .value: "bar",
        .path: "/",
        .originURL: "http://www.api.com",
        .expires: Date(timeIntervalSinceNow: 60)
        ]
        )!
    
    let csrftokenCookie = HTTPCookie(properties: [
        .name: "csrftoken",
        .value: "bar",
        .path: "/",
        .originURL: "http://www.api.com",
        .expires: Date(timeIntervalSinceNow: 60)
        ]
        )!
    
    func testMakePOSTURLRequest() {
        let requestBuilder = APIConnectionRequestBuilder(baseURL: URL(string:"http://www.api.com")!, cookies: [cookie])
        let result = requestBuilder.makeURLRequest(path: "/test", payload: ["hello": "world"])
        
        var expectedResult = URLRequest(url: URL(string:"http://www.api.com/test")!)
        expectedResult.httpMethod = "POST"
        expectedResult.httpBody = "{\"hello\":\"world\"}".data(using: .utf8)
        expectedResult.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        expectedResult.addValue("https://www.instagram.com/", forHTTPHeaderField: "referer")
        expectedResult.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: [cookie])
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testMakeGETURLRequest() {
        let requestBuilder = APIConnectionRequestBuilder(baseURL: URL(string:"http://www.api.com")!, cookies: [cookie])
        let result = requestBuilder.makeURLRequest(path: "/test", payload: nil)
        
        var expectedResult = URLRequest(url: URL(string:"http://www.api.com/test")!)
        expectedResult.httpMethod = "GET"
        expectedResult.httpBody = nil
        expectedResult.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        expectedResult.addValue("https://www.instagram.com/", forHTTPHeaderField: "referer")
        expectedResult.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: [cookie])
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testMakeURLRequestWith_csrftoken() {
        let requestBuilder = APIConnectionRequestBuilder(baseURL: URL(string:"http://www.api.com")!, cookies: [cookie, csrftokenCookie])
        let result = requestBuilder.makeURLRequest(path: "/test", payload: nil)
        
        var expectedResult = URLRequest(url: URL(string:"http://www.api.com/test")!)
        expectedResult.httpMethod = "GET"
        expectedResult.httpBody = nil
        expectedResult.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        expectedResult.addValue("https://www.instagram.com/", forHTTPHeaderField: "referer")
        expectedResult.addValue("bar", forHTTPHeaderField: "x-csrftoken")
        expectedResult.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: [cookie, csrftokenCookie])
        
        XCTAssertEqual(result, expectedResult)
    }
    
}
