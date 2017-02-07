//
//  LikeReqestsManagerTests.swift
//  InstagramData
//
//  Created by Ben Davis on 28/01/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import XCTest
@testable import InstagramData
import SwiftToolbox
import RealmSwift

class LikeReqestsManagerTests: XCTestCase {
    
    var reachability: MockReachability!
    var taskDispatcher: MockTaskDispatcher!
    var reliableNetworkTaskManager: MockReliableNetworkTaskManager!
    var mockCommunicator: MockAPICommunicator!
    var mediaDataStore: MockMediaDataStore!
    var sut: LikeReqestsManager!
    
    override func setUp() {
        try? FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
        
        reachability = MockReachability()
        taskDispatcher = MockTaskDispatcher()
        reliableNetworkTaskManager = MockReliableNetworkTaskManager(reachability: reachability,
                                                                    taskDispatcher: taskDispatcher)
        mockCommunicator = MockAPICommunicator()
        mediaDataStore = MockMediaDataStore()
        sut = LikeReqestsManager(communicator: mockCommunicator,
                                 mediaDataStore: mediaDataStore,
                                 reliableNetworkTaskManager: reliableNetworkTaskManager)
        
        mockCommunicator.testResponse = APIResponse(responseCode: 200,
                                                    responseBody: [:],
                                                    urlResponse: nil)
    }
    
    func testCanLikePost() {
        let postId = "12345"
        sut.likePost(with: postId)
        XCTAssertEqual(mockCommunicator.likePostCallCount, 1)
        XCTAssertEqual(mockCommunicator.likePostParameter, postId)
    }
    
    func testCanUnlikePost() {
        let postId = "12345"
        sut.unlikePost(with: postId)
        XCTAssertEqual(mockCommunicator.unlikePostCallCount, 1)
        XCTAssertEqual(mockCommunicator.unlikePostParameter, postId)
    }
    
    func testUsesReliableNetworkTask() {

        reliableNetworkTaskManager.performTaskCalled = false
        sut.likePost(with: "12345")
        XCTAssert(reliableNetworkTaskManager.performTaskCalled)
        
        reliableNetworkTaskManager.performTaskCalled = false
        sut.unlikePost(with: "12345")
        XCTAssert(reliableNetworkTaskManager.performTaskCalled)
    }
    
    func testRetriesLikeIfFails() {
        
        taskDispatcher.forceSynchronous = false
        
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
        sut = LikeReqestsManager(communicator: mockCommunicator,
                                 mediaDataStore: mediaDataStore,
                                 reliableNetworkTaskManager: reliableNetworkTaskManager)
        
        let postId = "12345"
        sut.likePost(with: postId)
        
        waitForExpectations(timeout: 0.01)
        XCTAssertEqual(mockCommunicator.likePostCallCount, 2)
    }
    
    func testRetriesUnlikeIfFails() {
        
        taskDispatcher.forceSynchronous = false
        
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
        sut = LikeReqestsManager(communicator: mockCommunicator,
                                 mediaDataStore: mediaDataStore,
                                 reliableNetworkTaskManager: reliableNetworkTaskManager)
        
        let postId = "12345"
        sut.unlikePost(with: postId)
        
        waitForExpectations(timeout: 0.01)
        XCTAssertEqual(mockCommunicator.unlikePostCallCount, 2)
    }
    
    func testLikeCancelledIfUnlikeCalledAfter() {
        reachability.testReachability = .NotReachable
        
        let postId = "12345"
        sut.likePost(with: postId)
        sut.unlikePost(with: postId)
        
        reachability.testReachability = .ReachableViaWiFi
        reachability.reachableBlock?(nil)
        
        XCTAssertEqual(mockCommunicator.likePostCallCount, 0)
        XCTAssertEqual(mockCommunicator.unlikePostCallCount, 1)
    }
    
    func testUnlikeCancelledIfLikeCalledAfter() {
        reachability.testReachability = .NotReachable
        
        let postId = "12345"
        sut.unlikePost(with: postId)
        sut.likePost(with: postId)
        
        reachability.testReachability = .ReachableViaWiFi
        reachability.reachableBlock?(nil)
        
        XCTAssertEqual(mockCommunicator.likePostCallCount, 1)
        XCTAssertEqual(mockCommunicator.unlikePostCallCount, 0)
    }
    
    func testCanLikeAndUnlikePostMultipleTimes() {
        let postId = "12345"
        sut.likePost(with: postId)
        sut.unlikePost(with: postId)
        sut.likePost(with: postId)
        sut.unlikePost(with: postId)
        XCTAssertEqual(mockCommunicator.likePostCallCount, 2)
        XCTAssertEqual(mockCommunicator.unlikePostCallCount, 2)
    }
    
}
