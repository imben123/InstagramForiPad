//
//  MediaManagerTests.swift
//  InstagramData
//
//  Created by Ben Davis on 07/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import XCTest
import SwiftToolbox
@testable import InstagramData

class MediaManagerTestsExamples: ResourceLoader {
    
    static let rawFeedJson: [String:Any] = getObject(with: "Media.json")
}

class MediaManagerTests: XCTestCase {
    
    var mockCommunicator: MockAPICommunicator!
    var mediaDataStore: MockMediaDataStore!
    var taskDispatcher: TaskDispatcher!
        
    var sut: MediaManager!
    
    override func setUp() {
        taskDispatcher = MockTaskDispatcher()
        mockCommunicator = MockAPICommunicator()
        mediaDataStore = MockMediaDataStore()
        sut = MediaManager(communicator: mockCommunicator,
                           mediaDataStore: mediaDataStore,
                           taskDispatcher: taskDispatcher)
    }
    
    func testUpdateMediaCalledGetPost() {
        
        // When
        let exampleMediaItem = MediaItem(id: "")
        sut.updateMediaItem(exampleMediaItem)
        
        // Then
        XCTAssertEqual(self.mockCommunicator.getPostCallCount, 1)
        XCTAssertEqual(self.mockCommunicator.getPostParameter, exampleMediaItem.code)
    }
    
    func testUpdatePostParsesMediaItem() {
        // Given
        mockCommunicator.testResponse = APIResponse(responseCode: 200, 
                                                    responseBody: MediaManagerTestsExamples.rawFeedJson,
                                                    urlResponse: nil)
        
        let expectation = self.expectation(description: "Completion closure called")
        
        // When
        let exampleMediaItem = MediaItem(id: "1509549928887982131", code: "BTy_6mSFZgz")
        sut.updateMediaItem(exampleMediaItem) { mediaItem in
            
            // Then
            expectation.fulfill()
            XCTAssertEqual(mediaItem.code, "BTy_6mSFZgz")
            XCTAssertEqual(mediaItem.id, "1509549928887982131")
        }
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testUpdatePostSavesNewPostToMediaStore() {
        // Given
        mockCommunicator.testResponse = APIResponse.init(responseCode: 200,
                                                         responseBody: MediaManagerTestsExamples.rawFeedJson,
                                                         urlResponse: nil)
        
        // When
        let exampleMediaItem = MediaItem(id: "1509549928887982131", code: "BTy_6mSFZgz")
        sut.updateMediaItem(exampleMediaItem)

        // Then
        XCTAssertEqual(mediaDataStore.archivedMediaList?.count, 1)
        XCTAssertEqual(mediaDataStore.archivedMediaList?.first?.code, "BTy_6mSFZgz")
        XCTAssertEqual(mediaDataStore.archivedMediaList?.first?.id, "1509549928887982131")
    }
    
}
