//
//  AuthManagerAuthenticatedTests.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import XCTest
@testable import InstagramData

class AuthManagerAuthenticatedTests: XCTestCase {
    
    var sut: AuthManager!
    var mockCommunicator: MockAPICommunicator!
    
    override func setUp() {
        super.setUp()
        mockCommunicator = MockAPICommunicator()
        sut = AuthManager(communicator: mockCommunicator)
    }
    
    func testAuthenticated() {
        mockCommunicator.testAuthenticated = false
        XCTAssertFalse(sut.authenticated)
        
        mockCommunicator.testAuthenticated = true
        XCTAssertTrue(sut.authenticated)
    }
    
}
