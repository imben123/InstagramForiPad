//
//  AuthManagerLoginTests.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import XCTest
@testable import InstagramData

struct AuthManagerTestsExamples {
    
    static let exampleLoginSuccessResponse = APIResponse(
        responseCode: 200,
        responseBody: [
            "user": "username",
            "status": "ok",
            "authenticated": true
        ], urlResponse: nil)
    
    static let exampleLoginFailedResponse = APIResponse(
        responseCode: 200,
        responseBody: [
            "user": "username",
            "status": "ok",
            "authenticated": false
        ], urlResponse: nil)
    
}

class AuthManagerLoginTests: XCTestCase {
    
    var sut: AuthManager!
    var mockCommunicator: MockAPICommunicator!
    
    override func setUp() {
        super.setUp()
        mockCommunicator = MockAPICommunicator()
        sut = AuthManager(communicator: mockCommunicator)
    }
    
    func testLoginCompletionCalledOnSuccess() {
        
        // Given
        let username = "username"
        let password = "password"
        mockCommunicator.testResponse = AuthManagerTestsExamples.exampleLoginSuccessResponse
        
        
        // When
        let expectation = self.expectation(description: "Completion/Failure called")
        
        var completionCalled = false
        var failureCalled = false
        sut.login(username: username, password: password, completion: {
            completionCalled = true
            expectation.fulfill()
        }, failure: {
            failureCalled = true
            expectation.fulfill()
        })
        
        self.waitForExpectations(timeout: 0.1)
        
        // Then
        XCTAssertTrue(completionCalled)
        XCTAssertFalse(failureCalled)
    }
    
    func testLoginFailureCalledOnInvalidLoginDetails() {
        
        // Given
        let username = "username"
        let password = "password"
        mockCommunicator.testResponse = AuthManagerTestsExamples.exampleLoginFailedResponse
        
        
        // When
        let expectation = self.expectation(description: "Completion/Failure called")
        
        var completionCalled = false
        var failureCalled = false
        sut.login(username: username, password: password, completion: {
            completionCalled = true
            expectation.fulfill()
        }, failure: {
            failureCalled = true
            expectation.fulfill()
        })
        
        self.waitForExpectations(timeout: 0.1)
        
        // Then
        XCTAssertFalse(completionCalled)
        XCTAssertTrue(failureCalled)
    }
    
    func testLoginFailureCalledOnFailedRequest() {
        
        // Given
        let username = "username"
        let password = "password"
        
        // When
        let expectation = self.expectation(description: "Completion/Failure called")
        
        var completionCalled = false
        var failureCalled = false
        sut.login(username: username, password: password, completion: {
            completionCalled = true
            expectation.fulfill()
        }, failure: {
            failureCalled = true
            expectation.fulfill()
        })
        
        self.waitForExpectations(timeout: 0.1)
        
        // Then
        XCTAssertFalse(completionCalled)
        XCTAssertTrue(failureCalled)
    }
    
}
