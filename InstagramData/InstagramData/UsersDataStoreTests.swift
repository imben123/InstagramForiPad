//
//  UsersDataStoreTests.swift
//  InstagramData
//
//  Created by Ben Davis on 06/05/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import XCTest
import SwiftToolbox
@testable import InstagramData

struct UsersDataStoreTestsExamples {
    
    static let exampleSuccessUserResponse = APIResponse(
        responseCode: 200,
        responseBody: UserTests.getUserObject(),
        urlResponse: nil)
    
}

class UsersDataStoreTests: XCTestCase {

    var sut: UsersDataStore!
    var mockCommunicator: MockAPICommunicator!
    
    override func setUp() {
        super.setUp()
        let taskDispatch = MockTaskDispatcher()
        mockCommunicator = MockAPICommunicator(APIConnection())
        sut = UsersDataStore(communicator: mockCommunicator, taskDispatcher: taskDispatch)
    }
    
    func testCanAddUser() {
        let user = User(id: "id")
        sut.addUser(user)
    }
    
    func testCanRetrieveAddedUser() {
        let user = User(id: "id")
        sut.addUser(user)
        var result: User? = nil
        sut.fetchUser(for: "id") { result = $0 }
        XCTAssertEqual(result, user)
    }
    
    func testGettingUserNotAddedWillDownloadUser() {
        
        mockCommunicator.testResponse = UsersDataStoreTestsExamples.exampleSuccessUserResponse
        
        var completionCalled = false
        sut.fetchUser(for: "1417593507") { user in
            
            guard let user = user else {
                XCTFail("Returned nil user")
                return
            }
            
            XCTAssertEqual(user.id, "1417593507")
            XCTAssertEqual(user.fullName, "Liza D")
            completionCalled = true
        }
        XCTAssert(completionCalled)
    }
    
    func testNilReturnedOnFailure() {
        mockCommunicator.testResponse = APIResponse.noInternetResponse
        
        var completionCalled = false
        sut.fetchUser(for: "1417593507") { user in
            
            guard user == nil else {
                XCTFail("Returned nil user")
                return
            }
            
            completionCalled = true
        }
        XCTAssert(completionCalled)
    }
    
    func testGettingPreviouslyFetchedUserReturnsCachedUser() {
        mockCommunicator.testResponse = UsersDataStoreTestsExamples.exampleSuccessUserResponse
        
        var result1: User? = nil
        sut.fetchUser(for: "1417593507", completion: { result1 = $0 })
        
        var result2: User? = nil
        sut.fetchUser(for: "1417593507", completion: { result2 = $0 })
        
        XCTAssertEqual(result1, result2)
        XCTAssertEqual(mockCommunicator.getUserCallCount, 1)
    }
    
    func testForceUpdateDoesNotReturnCachedUser() {
        mockCommunicator.testResponse = UsersDataStoreTestsExamples.exampleSuccessUserResponse
        
        sut.fetchUser(for: "1417593507", completion: { let _ = $0 })
        sut.fetchUser(for: "1417593507", forceUpdate: true, completion: { let _ = $0 })
        
        XCTAssertEqual(mockCommunicator.getUserCallCount, 2)
    }
    
}
