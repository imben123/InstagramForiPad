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
    var mockMediaDataStore: MockMediaDataStore!
    var mockMediaListDataStore: MockMediaListDataStore!
    var mediaList: ScrollingMediaList!
    
    override func setUp() {
        super.setUp()
        mockCommunicator = MockAPICommunicator()
        mockMediaDataStore = MockMediaDataStore()
        mockMediaListDataStore = MockMediaListDataStore()
        mediaList = ScrollingMediaList(name: "feed",
                                       pageSize: 50,
                                       mediaDataStore: mockMediaDataStore,
                                       listDataStore: mockMediaListDataStore)
        sut = FeedManager(communicator: mockCommunicator, mediaList: mediaList)
    }
    
    func testMediaIsEmptyOnCreate() {
        XCTAssertEqual(sut.mediaCount, 0)
        XCTAssertEqual(sut.mediaIDs, [])
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
        XCTAssertEqual(sut.mediaCount, 1)
        
        let mediaItemID = sut.mediaIDs.first!
        XCTAssertEqual(mediaItemID, "1416818863685651136")
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
        

        XCTAssertEqual(sut.mediaCount, 1)
    }
    
    func testMoreMediaAddedToEndOfArray() {
        
        mockCommunicator.testResonse = FeedManagerTestsExamples.exampleFetchMediaSuccessResponse
        
        // When
        var originalMediaItem: String? = nil
        let expectation = self.expectation(description: "Completion called")
        sut.fetchNewestMedia({
            XCTAssertEqual(self.sut.mediaCount, 1)
            originalMediaItem = self.sut.mediaIDs.first!
            self.mockCommunicator.testResonse = FeedManagerTestsExamples.exampleFetchMoreMediaSuccessResponse
            self.sut.fetchMoreMedia({
                expectation.fulfill()
            })
        })
        self.waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(sut.mediaCount, 2)
        XCTAssertNotEqual(sut.mediaIDs.last, originalMediaItem)
        XCTAssertEqual(sut.mediaIDs.first, originalMediaItem)
    }
    
    func testNewMediaAddedToBeginningOfArray() {
        
        mockCommunicator.testResonse = FeedManagerTestsExamples.exampleFetchMediaSuccessResponse
        
        // When
        var originalMediaItem: String? = nil
        let expectation = self.expectation(description: "Completion called")
        sut.fetchNewestMedia({
            XCTAssertEqual(self.sut.mediaCount, 1)
            originalMediaItem = self.sut.mediaIDs.first!
            self.mockCommunicator.testResonse = FeedManagerTestsExamples.exampleFetchNewMediaWithOverlapSuccessResponse
            self.sut.fetchNewestMedia({
                expectation.fulfill()
            })
        })
        self.waitForExpectations(timeout: 1000)
        
        XCTAssertEqual(sut.mediaCount, 2)
        XCTAssertNotEqual(sut.mediaIDs.first, originalMediaItem)
        XCTAssertEqual(sut.mediaIDs.last, originalMediaItem)
    }
    
    func testOldMediaDroppedIfNewMediaDoesNotOverlapOldMedia() {
        
        mockCommunicator.testResonse = FeedManagerTestsExamples.exampleFetchMediaSuccessResponse
        
        // When
        var originalMediaItem: String? = nil
        let expectation = self.expectation(description: "Completion called")
        sut.fetchNewestMedia({
            XCTAssertEqual(self.sut.mediaCount, 1)
            originalMediaItem = self.sut.mediaIDs.first!
            self.mockCommunicator.testResonse = FeedManagerTestsExamples.exampleFetchMoreMediaSuccessResponse
            self.sut.fetchNewestMedia({
                expectation.fulfill()
            })
        })
        self.waitForExpectations(timeout: 1000)
        
        XCTAssertEqual(sut.mediaCount, 1)
        XCTAssertNotEqual(sut.mediaIDs.first, originalMediaItem)
    }
    
    func testCanGetMediaCount() {
        
        // Given
        XCTAssertEqual(sut.mediaCount, 0)
        mockCommunicator.testResonse = FeedManagerTestsExamples.exampleFetchMediaSuccessResponse
        
        // When
        let expectation = self.expectation(description: "Completion called")
        sut.fetchMoreMedia({
            expectation.fulfill()
        })
        self.waitForExpectations(timeout: 0.1)
        
        // Then
        XCTAssertEqual(sut.mediaCount, 1)
    }
    
    func testCanGetMediaItemForID() {
        
        // Given
        XCTAssertEqual(sut.mediaCount, 0)
        let expected = MediaItem(id: "1416818863685651136")
        mockMediaDataStore.mediaItemToLoad = expected
        mockCommunicator.testResonse = FeedManagerTestsExamples.exampleFetchMediaSuccessResponse

        // When
        let expectation = self.expectation(description: "Completion called")
        sut.fetchMoreMedia({
            // Then
            self.sut.mediaItem(for: "1416818863685651136") { mediaItem in
                XCTAssertEqual(mediaItem, expected)
                expectation.fulfill()
            }
        })
        
        self.waitForExpectations(timeout: 0.1)
    }
    
    func testPrefetchingDelegate() {
        
        class FakePrefetchingDelegate: FeedManagerPrefetchingDelegate {
            
            var delegateMethodCalled = false
            var delegateMethodParam1: FeedManager? = nil
            var delegateMethodParam2: [MediaItem]? = nil
            
            func feedManager(_ feedManager: FeedManager, prefetchDataFor mediaItems: [MediaItem]) {
                delegateMethodCalled = true
                delegateMethodParam1 = feedManager
                delegateMethodParam2 = mediaItems
            }
        }
        
        // Given
        let prefetchDelegate = FakePrefetchingDelegate()
        sut.prefetchingDelegate = prefetchDelegate
        
        let exampleMedia = [MediaItem(id: "1"), MediaItem(id: "2"), MediaItem(id: "3")]
        
        // When
        mediaList.prefetchingDelegate?.scrollingMediaList(mediaList, prefetchDataFor: exampleMedia)
        
        // Then
        XCTAssertTrue(prefetchDelegate.delegateMethodCalled)
        XCTAssert(prefetchDelegate.delegateMethodParam1! === sut)
        XCTAssertEqual(prefetchDelegate.delegateMethodParam2!, exampleMedia)
    }
}
