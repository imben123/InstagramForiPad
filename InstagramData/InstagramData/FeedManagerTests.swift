//
//  FeedManagerTests.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import XCTest
@testable import InstagramData

class FeedManagerTestsExamples: ResourceLoader {
    
    static let rawFeedJson: [String:Any] = getObject(with: "Feed.json")
    
    static let exampleFetchMediaSuccessResponse = APIResponse(
        responseCode: 200,
        responseBody: rawFeedJson,
        urlResponse: nil)
    
}

class FeedManagerTests: XCTestCase {
    
    var sut: FeedManager!
    var mockCommunicator: MockAPICommunicator!
    
    override func setUp() {
        super.setUp()
        mockCommunicator = MockAPICommunicator()
        sut = FeedManager(communicator: mockCommunicator)
    }
    
    func testMediaIsEmptyOnCreate() {
        let empty: [MediaItem] = []
        XCTAssertEqual(sut.media, empty)
    }
    
    func testFetchMoreMediaCompletionCalledOnSuccess() {
        
        // Given
        mockCommunicator.testResonse = FeedManagerTestsExamples.exampleFetchMediaSuccessResponse
        
        // When
        let expectation = self.expectation(description: "Completion/Failure called")
        
        var completionCalled = false
        var failureCalled = false
        sut.fetchMoreMedia({
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
    
    func testFetchMoreMediaFailureCalledOnFailure() {
        
        // When
        let expectation = self.expectation(description: "Completion/Failure called")
        
        var completionCalled = false
        var failureCalled = false
        sut.fetchMoreMedia({
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
    
    func testMediaAddedAfterFetch() {
        
        // Given
        mockCommunicator.testResonse = FeedManagerTestsExamples.exampleFetchMediaSuccessResponse
        
        // When
        let expectation = self.expectation(description: "Completion called")
        sut.fetchMoreMedia({
            expectation.fulfill()
        })
        self.waitForExpectations(timeout: 0.1)
        
        // Then
        XCTAssertEqual(sut.media.count, 24)
        
        let mediaItem = sut.media.first!
        XCTAssertEqual(mediaItem.id, "1416714076692007483")
        XCTAssertEqual(mediaItem.date, Date(timeIntervalSince1970: 1483105500))
        XCTAssertEqual(mediaItem.dimensions, CGSize(width: 1080, height: 1080))
        XCTAssertEqual(mediaItem.ownerId, "11905793")
        XCTAssertEqual(mediaItem.code, "BOpLfJZhco7")
        XCTAssertEqual(mediaItem.isVideo, false)
        XCTAssertNil(mediaItem.thumbnail)
        XCTAssertEqual(mediaItem.display, URL(string: "https://scontent-lhr3-1.cdninstagram.com/t51.2885-15/e35/15802885_364809080541183_2337535770459373568_n.jpg?ig_cache_key=MTQxNjcxNDA3NjY5MjAwNzQ4Mw%3D%3D.2"))
        XCTAssertEqual(mediaItem.commentsDisabled, false)
        XCTAssertEqual(mediaItem.commentsCount, 0)
        XCTAssertEqual(mediaItem.likesCount, 5)
    }
    
}
