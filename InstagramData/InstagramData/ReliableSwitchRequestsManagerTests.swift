//
//  ReliableRequestManagerTests.swift
//  InstagramData
//
//  Created by Ben Davis on 07/05/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import XCTest
@testable import InstagramData
import SwiftToolbox
import RealmSwift

class ReliableRequestManagerTests: XCTestCase {
    
    var reachability: MockReachability!
    var taskDispatcher: MockTaskDispatcher!
    var reliableNetworkTaskManager: MockReliableNetworkTaskManager!
    var mockCommunicator: MockAPICommunicator!
    var sut: ReliableSwitchRequestsManager!
    

    override func setUp() {
        try? FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
        
        reachability = MockReachability()
        taskDispatcher = MockTaskDispatcher()
        reliableNetworkTaskManager = MockReliableNetworkTaskManager(reachability: reachability,
                                                                    taskDispatcher: taskDispatcher)
        
        mockCommunicator = MockAPICommunicator()
        
        sut = ReliableSwitchRequestsManager(taskDispatcher: taskDispatcher,
                                            reliableNetworkTaskManager: reliableNetworkTaskManager,
                                            switchOnCall: mockCommunicator.likePost(with:),
                                            switchOffCall: mockCommunicator.unlikePost(with:))
        
        mockCommunicator.testResponse = APIResponse(responseCode: 200,
                                                    responseBody: [:],
                                                    urlResponse: nil)

    }
    
    func testPostSwitchOn() {
        let postId = "12345"
        sut.switchOn(for: postId)
        XCTAssertEqual(mockCommunicator.likePostCallCount, 1)
        XCTAssertEqual(mockCommunicator.likePostParameter, postId)
    }
    
    func testSwitchOnCompletion() {
        var completionCalled = false
        sut.switchOn(for: "12345") {
            completionCalled = true
        }
        XCTAssert(completionCalled)
    }
    
    func testPostSwitchOff() {
        let postId = "12345"
        sut.switchOff(for: postId)
        XCTAssertEqual(mockCommunicator.unlikePostCallCount, 1)
        XCTAssertEqual(mockCommunicator.unlikePostParameter, postId)
    }
    
    func testSwitchOffCompletion() {
        var completionCalled = false
        sut.switchOff(for: "12345") {
            completionCalled = true
        }
        XCTAssert(completionCalled)
    }
    
    func testUsesReliableNetworkTask() {
        
        reliableNetworkTaskManager.performTaskCalled = false
        sut.switchOn(for: "12345")
        XCTAssert(reliableNetworkTaskManager.performTaskCalled)
        
        reliableNetworkTaskManager.performTaskCalled = false
        sut.switchOff(for: "12345")
        XCTAssert(reliableNetworkTaskManager.performTaskCalled)
    }
    
    func testRetriesLikeIfFails() {
        
        class _MockAPICommunicator: MockAPICommunicator {
            
            var expectation: XCTestExpectation?
            
            override func likePost(with id: String) -> APIResponse {
                if likePostCallCount > 0 {
                    expectation?.fulfill()
                }
                let result = super.likePost(with: id)
                testResponse = APIResponse(responseCode: 200,
                                           responseBody: [:],
                                           urlResponse: nil)
                return result
            }
            
        }
        
        // Recreate sut
        let mockCommunicator = _MockAPICommunicator()
        mockCommunicator.expectation = self.expectation(description: "Like retried")
        sut = ReliableSwitchRequestsManager(taskDispatcher: taskDispatcher,
                                            reliableNetworkTaskManager: reliableNetworkTaskManager,
                                            switchOnCall: mockCommunicator.likePost(with:),
                                            switchOffCall: mockCommunicator.unlikePost(with:))
        
        let postId = "12345"
        var completionCallCount = 0
        sut.switchOn(for: postId) {
            completionCallCount += 1
        }
        
        waitForExpectations(timeout: 0.01)
        XCTAssertEqual(mockCommunicator.likePostCallCount, 2)
        XCTAssertEqual(completionCallCount, 1)
    }
    
    func testRetriesUnlikeIfFails() {
                
        class _MockAPICommunicator: MockAPICommunicator {
            
            var expectation: XCTestExpectation?
            
            override func unlikePost(with id: String) -> APIResponse {
                if unlikePostCallCount > 0 {
                    expectation?.fulfill()
                }
                let result = super.unlikePost(with: id)
                testResponse = APIResponse(responseCode: 200,
                                           responseBody: [:],
                                           urlResponse: nil)
                return result
            }
            
        }
        
        // Recreate sut
        let mockCommunicator = _MockAPICommunicator()
        mockCommunicator.expectation = self.expectation(description: "Unlike retried")
        sut = ReliableSwitchRequestsManager(taskDispatcher: taskDispatcher,
                                            reliableNetworkTaskManager: reliableNetworkTaskManager,
                                            switchOnCall: mockCommunicator.likePost(with:),
                                            switchOffCall: mockCommunicator.unlikePost(with:))
        
        let postId = "12345"
        var completionCallCount = 0
        sut.switchOff(for: postId) {
            completionCallCount += 1
        }
        
        waitForExpectations(timeout: 0.01)
        XCTAssertEqual(mockCommunicator.unlikePostCallCount, 2)
        XCTAssertEqual(completionCallCount, 1)
    }
    
    func testSwitchOnCancelledIfSwitchOffCalledAfter() {
        reachability.testReachability = .NotReachable
        
        let postId = "12345"
        sut.switchOn(for: postId)
        sut.switchOff(for: postId)
        
        reachability.testReachability = .ReachableViaWiFi
        reachability.reachableBlock?(nil)
        
        XCTAssertEqual(mockCommunicator.likePostCallCount, 0)
        XCTAssertEqual(mockCommunicator.unlikePostCallCount, 1)
    }
    
    func testSwitchOffCancelledIfSwitchOnCalledAfter() {
        reachability.testReachability = .NotReachable
        
        let postId = "12345"
        sut.switchOff(for: postId)
        sut.switchOn(for: postId)
        
        reachability.testReachability = .ReachableViaWiFi
        reachability.reachableBlock?(nil)
        
        XCTAssertEqual(mockCommunicator.likePostCallCount, 1)
        XCTAssertEqual(mockCommunicator.unlikePostCallCount, 0)
    }
    
    func testCanSwitchOnAndOffMultipleTimes() {
        let postId = "12345"
        sut.switchOn(for: postId)
        sut.switchOff(for: postId)
        sut.switchOn(for: postId)
        sut.switchOff(for: postId)
        XCTAssertEqual(mockCommunicator.likePostCallCount, 2)
        XCTAssertEqual(mockCommunicator.unlikePostCallCount, 2)
    }
    
}
