//
//  AuthManagerLogoutTests.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import XCTest
@testable import InstagramData

class AuthManagerLogoutTests: XCTestCase {
    
    var sut: AuthManager!
    var mockCommunicator: MockAPICommunicator!
    
    let cookie = HTTPCookie(properties: [
        .name: "foo",
        .value: "bar",
        .path: "/",
        .originURL: "http://www.api.com",
        .expires: Date(timeIntervalSinceNow: 60)
        ]
        )!
    
    override func setUp() {
        super.setUp()
        mockCommunicator = MockAPICommunicator()
        sut = AuthManager(communicator: mockCommunicator)
    }
    
    func testLogoutClearsCookies() {
        HTTPCookieStorage.shared.setCookie(cookie)
        sut.logout()
        XCTAssertEqual(HTTPCookieStorage.shared.cookies!.count, 0)
    }
    
}
