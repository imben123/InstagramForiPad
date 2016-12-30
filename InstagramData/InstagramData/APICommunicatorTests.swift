//
//  APICommunicatorTests.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import XCTest
@testable import InstagramData

class APICommunicatorTests: XCTestCase {
    
    var sut: APICommunicator!
    var mockConnection: MockAPIConnection!
    
    let expectedResponse = APIResponse(responseCode: 123, responseBody: ["foo": "bar"], urlResponse: nil)
    
    override func setUp() {
        super.setUp()
        mockConnection = MockAPIConnection()
        mockConnection.testResponse = expectedResponse
        sut = APICommunicator(mockConnection)
    }
    
    func testAuthenticated() {
        mockConnection.testAuthenticated = false
        XCTAssertFalse(sut.authenticated)
        
        mockConnection.testAuthenticated = true
        XCTAssertTrue(sut.authenticated)
    }
    
    func testLogin() {
        let response = sut.login(username: "username", password: "password")
        XCTAssertEqual(mockConnection.makeRequestCalls.count, 1)
        XCTAssertEqual(mockConnection.makeRequestCalls.first!.path, "/accounts/login/ajax/")
        XCTAssertEqual(mockConnection.makeRequestCalls.first!.payload!, [
            "username": "username",
            "password": "password"
            ])
        XCTAssertEqual(response, expectedResponse)
    }
    
    func testGetFeed() {
        let response = sut.getFeed()
        XCTAssertEqual(mockConnection.makeRequestCalls.count, 1)
        XCTAssertEqual(mockConnection.makeRequestCalls.first!.path, "/?__a=1")
        XCTAssertNil(mockConnection.makeRequestCalls.first!.payload)
        XCTAssertEqual(response, expectedResponse)
    }
}
