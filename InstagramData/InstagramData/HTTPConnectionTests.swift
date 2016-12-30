//
//  HTTPConnectionTests.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import XCTest
@testable import InstagramData

struct TestError: Error {
    
}

struct HTTPConnectionTestHelper {
    
    static let exampleResponseCode = 200
    static let exampleResponseBody = [ "foo": "bar" ]
    static let exampleURLReponse = HTTPURLResponse(url: URL(string: "http://www.google.com")!,
                                            statusCode: 200,
                                            httpVersion: nil,
                                            headerFields: ["Set-Cookie": "foo=bar; expires=Thu, 29-Dec-2999 15:32:04 GMT; Path=/"])!
    static let exampleError: Error = TestError()
    
    static func mockURLSessionWithSuccessfulResponse() -> MockURLSession {
        let mockURLSession = MockURLSession()
        mockURLSession.response = HTTPConnectionTestHelper.exampleURLReponse
        mockURLSession.error = nil
        mockURLSession.responseBody = try! JSONSerialization.data(
            withJSONObject: HTTPConnectionTestHelper.exampleResponseBody, options: []
        )
        return mockURLSession
    }
    
    static func makeSynchronousRequest(mockURLSession: MockURLSession) -> APIResponse? {
        let connection = HTTPConnection(session: mockURLSession)
        let request = URLRequest(url: URL(string: "myapi.com")!)
        return connection.makeSynchronousRequest(request)
    }
}

class HTTPConnectionTests: XCTestCase {
    
    var cookiesRecieved: [HTTPCookie] = []
    
    override func setUp() {
        super.setUp()
        cookiesRecieved = []
    }
    
}

extension HTTPConnectionTests {
    
    func testMakeRequest() {
        
        let mockURLSession = HTTPConnectionTestHelper.mockURLSessionWithSuccessfulResponse()
        
        let result = HTTPConnectionTestHelper.makeSynchronousRequest(mockURLSession: mockURLSession)!
        
        XCTAssertEqual(result.responseCode, HTTPConnectionTestHelper.exampleResponseCode)
        XCTAssertEqual(result.responseBody as! [String: String], HTTPConnectionTestHelper.exampleResponseBody)
        XCTAssertEqual(result.urlResponse!, HTTPConnectionTestHelper.exampleURLReponse)
    }
    
    func testErrorRequest() {
        
        let mockURLSession = HTTPConnectionTestHelper.mockURLSessionWithSuccessfulResponse()
        mockURLSession.response = nil
        mockURLSession.error = HTTPConnectionTestHelper.exampleError
        mockURLSession.responseBody = nil
        
        let result = HTTPConnectionTestHelper.makeSynchronousRequest(mockURLSession: mockURLSession)
        
        XCTAssertNil(result)
    }
    
    func testNilResponseRequest() {
        
        let mockURLSession = HTTPConnectionTestHelper.mockURLSessionWithSuccessfulResponse()
        mockURLSession.responseBody = nil
        
        let result = HTTPConnectionTestHelper.makeSynchronousRequest(mockURLSession: mockURLSession)!
        
        XCTAssertEqual(result.responseCode, HTTPConnectionTestHelper.exampleResponseCode)
        XCTAssertNil(result.responseBody)
        XCTAssertEqual(result.urlResponse!, HTTPConnectionTestHelper.exampleURLReponse)
    }
    
    func testNonJsonResponseRequest() {
        
        let mockURLSession = HTTPConnectionTestHelper.mockURLSessionWithSuccessfulResponse()
        mockURLSession.responseBody = "Foo Bar".data(using: .utf8)
        
        let result = HTTPConnectionTestHelper.makeSynchronousRequest(mockURLSession: mockURLSession)!
        
        XCTAssertEqual(result.responseCode, HTTPConnectionTestHelper.exampleResponseCode)
        XCTAssertNil(result.responseBody)
        XCTAssertEqual(result.urlResponse!, HTTPConnectionTestHelper.exampleURLReponse)
    }
}

extension HTTPConnectionTests: HTTPConnectionDelegate  {
    
    func testSetCookieValuesReturnedToDelegate() {
        let mockURLSession = HTTPConnectionTestHelper.mockURLSessionWithSuccessfulResponse()
        let connection = HTTPConnection(session: mockURLSession)
        connection.delegate = self
        let _ = connection.makeSynchronousRequest(URLRequest(url: URL(string: "myapi.com")!))
        XCTAssertEqual(cookiesRecieved.count, 1)
        XCTAssertEqual(cookiesRecieved[0].name, "foo")
        XCTAssertEqual(cookiesRecieved[0].value, "bar")
    }
    
    func httpConnection(_ sender: HTTPConnection, receivedCookie cookie: HTTPCookie) {
        cookiesRecieved.append(cookie)
    }
}
