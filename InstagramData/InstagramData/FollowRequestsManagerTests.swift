//
//  FollowRequestsManagerTests.swift
//  InstagramData
//
//  Created by Ben Davis on 08/05/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import XCTest
import SwiftToolbox
@testable import InstagramData

class FollowRequestsManagerTests: XCTestCase {
    
    var sut: FollowRequestsManager!
    
    var reachability: MockReachability!
    var taskDispatcher: MockTaskDispatcher!
    var reliableNetworkTaskManager: MockReliableNetworkTaskManager!

    var mockCommunicator: MockAPICommunicator!
    var mockConnection: MockAPIConnection!
    
    override func setUp() {
        super.setUp()
        
        reachability = MockReachability()
        taskDispatcher = MockTaskDispatcher()
        reliableNetworkTaskManager = MockReliableNetworkTaskManager(reachability: reachability,
                                                                    taskDispatcher: taskDispatcher)
        
        mockConnection = MockAPIConnection()
        mockCommunicator = MockAPICommunicator(mockConnection)
        
        mockCommunicator.testResponse = APIResponse(responseCode: 301,
                                                    responseBody: [:],
                                                    urlResponse: nil)
        
        sut = FollowRequestsManager(communicator: mockCommunicator,
                                    taskDispatcher: taskDispatcher,
                                    reliableNetworkTaskManager: reliableNetworkTaskManager)
    }
    
    func testPostsFollowUser() {
        let userId = "12345"
        sut.followUser(with: userId)
        XCTAssertEqual(mockCommunicator.followUserCallCount, 1)
        XCTAssertEqual(mockCommunicator.followUserParameter, userId)
    }
    
    func testPostsUnfollowUser() {
        let userId = "12345"
        sut.unfollowUser(with: userId)
        XCTAssertEqual(mockCommunicator.unfollowUserCallCount, 1)
        XCTAssertEqual(mockCommunicator.unfollowUserParameter, userId)
    }
}
