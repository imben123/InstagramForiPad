//
//  APIConnectionTests.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import XCTest
@testable import InstagramData

struct APIConnectionTestsExamples {
    
    static let expectedRequest = createExpectedRequest()

    static let expectedBootrapRequest = createExpectedBootstrapRequest()

    static let exampleReponse = HTTPURLResponse(url: URL(string: "http://www.instagram.com/")!,
                                                statusCode: 200,
                                                httpVersion: nil,
                                                headerFields: ["Set-Cookie": "csrftoken=bar; expires=Thu, 29-Dec-2999 15:32:04 GMT; Path=/"])!
    
    static let exampleLoginReponse =
        HTTPURLResponse(url: URL(string: "http://www.instagram.com/")!,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: ["Set-Cookie": "sessionid=bar; expires=Thu, 29-Dec-2999 15:32:04 GMT; Path=/"])!
    
    static let exampleFailedLoginReponse =
        HTTPURLResponse(url: URL(string: "http://www.instagram.com/")!,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: ["Set-Cookie": "sessionid=; expires=Thu, 29-Dec-2999 15:32:04 GMT; Path=/"])!
    
    static let exampleBootstrapReponse =
        HTTPURLResponse(url: URL(string: "http://www.instagram.com/")!,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: ["Set-Cookie": "csrftoken=bar; expires=Thu, 29-Dec-2999 15:32:04 GMT; Path=/"])!
    
    
    static let exampleBootstrapReponseWithExpiredCookie =
        HTTPURLResponse(url: URL(string: "http://www.instagram.com/")!,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: ["Set-Cookie": "csrftoken=bar; expires=Thu, 29-Dec-2999 15:32:04 GMT; Path=/, foo=bar; expires=Thu, 29-Dec-1999 15:32:04 GMT; Path=/"])!
    
    static let exampleResponseBody = ["hello": "world"]
    
    static let bootstrapCookie = HTTPCookie(properties: [
        .name: "csrftoken",
        .value: "bar",
        .path: "/",
        .originURL: "http://www.api.com",
        .expires: Date(timeIntervalSinceNow: 60)
        ]
        )!
    
    private static func createExpectedRequest() -> URLRequest {
        var expectedResult = URLRequest(url: URL(string:"https://www.instagram.com/test")!)
        expectedResult.httpMethod = "POST"
        expectedResult.httpBody = "{\"hello\":\"world\"}".data(using: .utf8)
        expectedResult.allHTTPHeaderFields =
            HTTPCookie.requestHeaderFields(with: [APIConnectionTestsExamples.bootstrapCookie])
        expectedResult.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        expectedResult.addValue("https://www.instagram.com/", forHTTPHeaderField: "referer")
        expectedResult.setValue("bar", forHTTPHeaderField: "x-csrftoken")
        return expectedResult
    }
    
    private static func createExpectedBootstrapRequest() -> URLRequest {
        var expectedResult = URLRequest(url: URL(string:"https://www.instagram.com/")!)
        expectedResult.httpMethod = "GET"
        expectedResult.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        expectedResult.addValue("https://www.instagram.com/", forHTTPHeaderField: "referer")
        return expectedResult
    }
    
}

class APIConnectionTests: XCTestCase {
    
    var mockSession: MockURLSession!
    var sut: APIConnection!
    
    override func setUp() {
        super.setUp()
        clearStoredCookies()
        mockSession =  HTTPConnectionTestHelper.mockURLSessionWithSuccessfulResponse()
        mockSession.response = APIConnectionTestsExamples.exampleReponse
        sut = APIConnection(connection: HTTPConnection(session: mockSession))
    }
    
    func clearStoredCookies() {
        let cookieStore = HTTPCookieStorage.shared
        if let cookies = cookieStore.cookies {
            for cookie in cookies {
                cookieStore.deleteCookie(cookie)
            }
        }
    }
    
    func testMakeRequest() {
        
        // When
        let response = sut.makeRequest(path: "/test", payload: APIConnectionTestsExamples.exampleResponseBody)
        
        // Then
        XCTAssertEqual(mockSession.requests.last!, APIConnectionTestsExamples.expectedRequest)
        XCTAssertEqual(response.responseCode, HTTPConnectionTestHelper.exampleResponseCode)
        XCTAssertEqual(response.responseBody as! [String: String], HTTPConnectionTestHelper.exampleResponseBody)
        XCTAssertEqual(response.urlResponse, APIConnectionTestsExamples.exampleReponse)
    }
    
    func testMakeRequestFirstCallsBootstrap() {

        // When
        makeExampleRequest()

        // Then
        XCTAssertEqual(mockSession.requests.first!, APIConnectionTestsExamples.expectedBootrapRequest)
    }
    
    func testBootstrapNotCalledIf_csrftoken_exists() {
        
        // Given
        setResponseToSuccessfulBootstrapResponse()
        makeExampleRequest()
        
        mockSession.requests = []
        setResponseToStandardResponse()
        
        // When
        makeExampleRequest()
        
        // Then
        XCTAssertEqual(mockSession.requests.count, 1)
        XCTAssertEqual(mockSession.requests.first!, APIConnectionTestsExamples.expectedRequest)
    }
    
    func testNotAuthenticatedIfNoCookieWith_sessionid() {
        XCTAssertFalse(sut.authenticated)
    }
    
    func testNotAuthenticatedIfCookieWithEmpty_sessionid() {

        // Given
        setResponseToUnsuccessfulLoginResponse() // Has empty string for sessionid
        makeExampleRequest()
        
        // Then
        XCTAssertFalse(sut.authenticated)
    }
    
    func testAuthenticatedIfCookieWith_sessionid() {

        // Given
        setResponseToSuccessfulLoginResponse()
        makeExampleRequest()
        
        // Then
        XCTAssertTrue(sut.authenticated)
    }
    
    func testExpiredCookiesAreRemoved() {
        
        // Given
        setResponseToSuccessfulBootstrapResponseWithExpiredCookie()
        makeExampleRequest()
        
        // When
        makeExampleRequest()
        
        // Then
        XCTAssertEqual(mockSession.requests.last!, APIConnectionTestsExamples.expectedRequest)
    }
    
    // MARK: - 
    
    func makeExampleRequest() {
        let _ = sut.makeRequest(path: "test", payload: APIConnectionTestsExamples.exampleResponseBody)
    }
}

extension APIConnectionTests {
    
    func setResponseToSuccessfulBootstrapResponse() {
        setReponse(APIConnectionTestsExamples.exampleBootstrapReponse)
    }
    
    func setResponseToSuccessfulBootstrapResponseWithExpiredCookie() {
        setReponse(APIConnectionTestsExamples.exampleBootstrapReponseWithExpiredCookie)
    }
    
    func setResponseToSuccessfulLoginResponse() {
        setReponse(APIConnectionTestsExamples.exampleLoginReponse)
    }
    
    func setResponseToUnsuccessfulLoginResponse() {
        setReponse(APIConnectionTestsExamples.exampleFailedLoginReponse)
    }
    
    func setResponseToStandardResponse() {
        setReponse(APIConnectionTestsExamples.exampleReponse)
    }
    
    func setReponse(_ response: URLResponse) {
        self.mockSession.response = response
    }
    
}
