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
    static let rawFeedPage2Json: [String:Any] = getObject(with: "FeedPage2.json")
    static let rawFeedUpdateOverlapping: [String:Any] = getObject(with: "FeedUpdateOverlapping.json")
    
    static let exampleFetchMediaSuccessResponse = APIResponse(
        responseCode: 200,
        responseBody: rawFeedJson,
        urlResponse: nil)
    
    static let exampleFetchMoreMediaSuccessResponse = APIResponse(
        responseCode: 200,
        responseBody: rawFeedPage2Json,
        urlResponse: nil)
    
    static let exampleFetchNewMediaWithOverlapSuccessResponse = APIResponse(
        responseCode: 200,
        responseBody: rawFeedUpdateOverlapping,
        urlResponse: nil)
    
}

class FeedManagerTests: XCTestCase {
    
    var sut: FeedManager!
    var mockCommunicator: MockAPICommunicator!
    
    override func setUp() {
        super.setUp()
        mockCommunicator = MockAPICommunicator()
        let mediaList = MediaList(dataStore: MockMediaDataStore(mediaOrigin: "mediaOrigin"))
        sut = FeedManager(communicator: mockCommunicator, mediaList: mediaList)
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
        XCTAssertEqual(sut.media.count, 1)
        
        let mediaItem = sut.media.first!
        XCTAssertEqual(mediaItem.id, "1416818863685651136")
        XCTAssertEqual(mediaItem.date, Date(timeIntervalSince1970: 1483117991))
        XCTAssertEqual(mediaItem.dimensions, CGSize(width: 750, height: 750))
        XCTAssertEqual(mediaItem.ownerId, "3053160285")
        XCTAssertEqual(mediaItem.code, "BOpjT_5DkrA")
        XCTAssertEqual(mediaItem.isVideo, false)
        XCTAssertEqual(mediaItem.thumbnail, URL(string: "https://scontent-lhr3-1.cdninstagram.com/t51.2885-15/s640x640/sh0.08/e35/15624418_1258813050862580_5354612363024662528_n.jpg?ig_cache_key=MTQxNjgxODg2MzY4NTY1MTEzNg%3D%3D.2"))
        XCTAssertEqual(mediaItem.display, URL(string: "https://scontent-lhr3-1.cdninstagram.com/t51.2885-15/s750x750/sh0.08/e35/15624418_1258813050862580_5354612363024662528_n.jpg?ig_cache_key=MTQxNjgxODg2MzY4NTY1MTEzNg%3D%3D.2"))
        XCTAssertEqual(mediaItem.commentsDisabled, false)
        XCTAssertEqual(mediaItem.commentsCount, 4)
        XCTAssertEqual(mediaItem.likesCount, 271)
    }
    
    func testCallingFetchManyTimesDoesntCauseDuplicates() {
        
        // Given
        mockCommunicator.testResonse = FeedManagerTestsExamples.exampleFetchMediaSuccessResponse
        
        let expectation1 = self.expectation(description: "Completion 1 called")
        sut.fetchNewestMedia({
            expectation1.fulfill()
        })
        
        let expectation2 = self.expectation(description: "Completion 2 called")
        sut.fetchMoreMedia({
            expectation2.fulfill()
        })
        
        let expectation3 = self.expectation(description: "Completion 3 called")
        sut.fetchMoreMedia({
            expectation3.fulfill()
        })
        
        let expectation4 = self.expectation(description: "Completion 4 called")
        sut.fetchMoreMedia({
            expectation4.fulfill()
        })
        
        self.waitForExpectations(timeout: 0.1)
        

        XCTAssertEqual(sut.media.count, 1)
    }
    
    func testMoreMediaAddedToEndOfArray() {
        
        mockCommunicator.testResonse = FeedManagerTestsExamples.exampleFetchMediaSuccessResponse
        
        // When
        var originalMediaItem: MediaItem? = nil
        let expectation = self.expectation(description: "Completion called")
        sut.fetchNewestMedia({
            XCTAssertEqual(self.sut.media.count, 1)
            originalMediaItem = self.sut.media.first!
            self.mockCommunicator.testResonse = FeedManagerTestsExamples.exampleFetchMoreMediaSuccessResponse
            self.sut.fetchMoreMedia({
                expectation.fulfill()
            })
        })
        self.waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(sut.media.count, 2)
        XCTAssertNotEqual(sut.media.last, originalMediaItem)
        XCTAssertEqual(sut.media.first, originalMediaItem)
    }
    
    func testNewMediaAddedToBeginningOfArray() {
        
        mockCommunicator.testResonse = FeedManagerTestsExamples.exampleFetchMediaSuccessResponse
        
        // When
        var originalMediaItem: MediaItem? = nil
        let expectation = self.expectation(description: "Completion called")
        sut.fetchNewestMedia({
            XCTAssertEqual(self.sut.media.count, 1)
            originalMediaItem = self.sut.media.first!
            self.mockCommunicator.testResonse = FeedManagerTestsExamples.exampleFetchNewMediaWithOverlapSuccessResponse
            self.sut.fetchNewestMedia({
                expectation.fulfill()
            })
        })
        self.waitForExpectations(timeout: 1000)
        
        XCTAssertEqual(sut.media.count, 2)
        XCTAssertNotEqual(sut.media.first, originalMediaItem)
        XCTAssertEqual(sut.media.last, originalMediaItem)
    }
    
    func testOldMediaDroppedIfNewMediaDoesNotOverlapOldMedia() {
        
        mockCommunicator.testResonse = FeedManagerTestsExamples.exampleFetchMediaSuccessResponse
        
        // When
        var originalMediaItem: MediaItem? = nil
        let expectation = self.expectation(description: "Completion called")
        sut.fetchNewestMedia({
            XCTAssertEqual(self.sut.media.count, 1)
            originalMediaItem = self.sut.media.first!
            self.mockCommunicator.testResonse = FeedManagerTestsExamples.exampleFetchMoreMediaSuccessResponse
            self.sut.fetchNewestMedia({
                expectation.fulfill()
            })
        })
        self.waitForExpectations(timeout: 1000)
        
        XCTAssertEqual(sut.media.count, 1)
        XCTAssertNotEqual(sut.media.first, originalMediaItem)
    }
    
}
