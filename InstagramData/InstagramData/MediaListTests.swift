//
//  MediaListTests.swift
//  InstagramData
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import XCTest
@testable import InstagramData

class MediaListTests: XCTestCase {
    
    let exampleListName = "Test Name"
    var mockMediaDataStore: MockMediaDataStore!
    var mockListDataStore: MockGappedListDataStore!
    var sut: MediaList!
    
    override func setUp() {
        super.setUp()
        mockMediaDataStore = MockMediaDataStore()
        mockListDataStore = MockGappedListDataStore()
        sut = MediaList(name: exampleListName, mediaDataStore: mockMediaDataStore, listDataStore: mockListDataStore)
    }
    
    func exampleMediaWithIDs(in range: CountableRange<Int>) -> [MediaItem] {
        var result: [MediaItem] = []
        for i in range {
            result.append(MediaItem(id: "\(i)"))
        }
        return result
    }
    
    func exampleMediaListWithIDs(in range: CountableRange<Int>) -> [GappedListItem] {
        var result: [GappedListItem] = []
        for i in range {
            result.append(GappedListItem(id: "\(i)"))
        }
        return result
    }
    
    func exampleMedia(withIDs ids: [Int]) -> [MediaItem] {
        var result: [MediaItem] = []
        for id in ids {
            result.append(MediaItem(id: "\(id)"))
        }
        return result
    }
    
    func exampleMediaList(withIDs ids: [Int]) -> [GappedListItem] {
        var result: [GappedListItem] = []
        for id in ids {
            result.append(GappedListItem(id: "\(id)"))
        }
        return result
    }
    
    func testMediaListEmptyIfNoArchive() {
        XCTAssertEqual(sut.listItems.count, 0)
        XCTAssertNil(sut.firstGapCursor)
    }
    
    func testAppendingMoreMediaDoesNotLeaveGap() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        
        sut.addNewMedia(exampleMediaWithIDs(in: 1..<4), with: endCursor1)
        sut.appendMoreMedia(exampleMediaWithIDs(in: 4..<7), from: endCursor1, to: endCursor2)
        
        
        let expectedListItems = [GappedListItem(id: "1"),
                                 GappedListItem(id: "2"),
                                 GappedListItem(id: "3"),
                                 GappedListItem(id: "4"),
                                 GappedListItem(id: "5"),
                                 GappedListItem(id: "6"),
                                 GappedListItem(gapCursor: endCursor2)]
        
        XCTAssertEqual(sut.listItems, expectedListItems)
    }
    
    func testFillingGapInMediaWithoutOverlap() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        let endCursor3 = "endCursor3"
        
        sut.addNewMedia(exampleMediaWithIDs(in: 8..<10), with: endCursor1)
        sut.addNewMedia(exampleMediaWithIDs(in: 1..<4), with: endCursor2)
        sut.appendMoreMedia(exampleMediaWithIDs(in: 4..<7), from: endCursor2, to: endCursor3)
        
        let expectedListItems = [GappedListItem(id: "1"),
                                 GappedListItem(id: "2"),
                                 GappedListItem(id: "3"),
                                 GappedListItem(id: "4"),
                                 GappedListItem(id: "5"),
                                 GappedListItem(id: "6"),
                                 GappedListItem(gapCursor: endCursor3),
                                 GappedListItem(id: "8"),
                                 GappedListItem(id: "9"),
                                 GappedListItem(gapCursor: endCursor1)]
        
        XCTAssertEqual(sut.listItems, expectedListItems)
        
    }
    
    func testFillingGapInMediaWithOverlapDoesNotLeaveGap() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        let endCursor3 = "endCursor3"
        
        sut.addNewMedia(exampleMedia(withIDs: [8,9]), with: endCursor1)
        sut.addNewMedia(exampleMedia(withIDs: [1,2,3]), with: endCursor2)
        sut.appendMoreMedia(exampleMedia(withIDs: [4,5,6,7,8]), from: endCursor2, to: endCursor3)
        
        let expectedListItems = [GappedListItem(id: "1"),
                                 GappedListItem(id: "2"),
                                 GappedListItem(id: "3"),
                                 GappedListItem(id: "4"),
                                 GappedListItem(id: "5"),
                                 GappedListItem(id: "6"),
                                 GappedListItem(id: "7"),
                                 GappedListItem(id: "8"),
                                 GappedListItem(id: "9"),
                                 GappedListItem(gapCursor: endCursor1)]
        
        XCTAssertEqual(sut.listItems, expectedListItems)
        
    }
    
    func testCanLoadMediaItemWithID() {
        mockMediaDataStore.mediaItemToLoad = MediaItem(id: "123")
        
        var completionCalled = false
        sut.mediaItem(for: "123") { [weak self] (mediaItem) in
            completionCalled = true
            XCTAssertEqual(mediaItem, MediaItem(id: "123"))
            XCTAssertEqual(self?.mockMediaDataStore.loadMediaItemIDParameter, "123")
        }
        XCTAssert(completionCalled)
    }
    
    // MARK: - archiving
    
    func testMediaUnarchivedOnLaunch() {
        let endCursor = "endCursor"
        mockMediaDataStore.archivedMediaList = exampleMedia(withIDs: [1,2,3])
        mockListDataStore.savedItemList = ([GappedListItem(id: "1"),
                                             GappedListItem(id: "2"),
                                             GappedListItem(id: "3"),
                                             GappedListItem(gapCursor: endCursor)], exampleListName)
        sut = MediaList(name: exampleListName, mediaDataStore: mockMediaDataStore, listDataStore: mockListDataStore)
        XCTAssertEqual(sut.listItems, mockListDataStore.savedItemList!.listItems)
    }
    
    func testMediaListArchivedOnAddingFirstMedia() {
        let endCursor = "endCursor"
        
        sut.addNewMedia(exampleMedia(withIDs: [1,2,3]), with: endCursor)
        let expectedListItems = [GappedListItem(id: "1"),
                                 GappedListItem(id: "2"),
                                 GappedListItem(id: "3"),
                                 GappedListItem(gapCursor: endCursor)]
        
        XCTAssertNotNil(mockListDataStore.savedItemList)
        XCTAssertEqual(mockListDataStore.savedItemList!.listItems, expectedListItems)
        XCTAssertEqual(mockListDataStore.savedItemList!.name, exampleListName)
    }
    
    func testMediaListArchivedOnAddingAddingMoreNewMedia() {
        let endCursor1 = "endCursor"
        let endCursor2 = "endCursor"
        
        sut.addNewMedia(exampleMedia(withIDs: [4,5,6]), with: endCursor2)
        sut.addNewMedia(exampleMedia(withIDs: [1,2,3]), with: endCursor1)
        let expectedListItems = [GappedListItem(id: "1"),
                                 GappedListItem(id: "2"),
                                 GappedListItem(id: "3"),
                                 GappedListItem(gapCursor: endCursor1),
                                 GappedListItem(id: "4"),
                                 GappedListItem(id: "5"),
                                 GappedListItem(id: "6"),
                                 GappedListItem(gapCursor: endCursor2)]
        
        XCTAssertNotNil(mockListDataStore.savedItemList)
        XCTAssertEqual(mockListDataStore.savedItemList!.listItems, expectedListItems)
        XCTAssertEqual(mockListDataStore.savedItemList!.name, exampleListName)
    }
    
    func testMediaListArchivedOnAppendingMoreMedia() {
        let endCursor1 = "endCursor"
        let endCursor2 = "endCursor"
        
        sut.addNewMedia(exampleMedia(withIDs: [1,2,3]), with: endCursor1)
        sut.appendMoreMedia(exampleMedia(withIDs: [4,5,6]), from: endCursor1, to: endCursor2)
        let expectedListItems = [GappedListItem(id: "1"),
                                 GappedListItem(id: "2"),
                                 GappedListItem(id: "3"),
                                 GappedListItem(id: "4"),
                                 GappedListItem(id: "5"),
                                 GappedListItem(id: "6"),
                                 GappedListItem(gapCursor: endCursor2)]
        
        XCTAssertNotNil(mockListDataStore.savedItemList)
        XCTAssertEqual(mockListDataStore.savedItemList!.listItems, expectedListItems)
        XCTAssertEqual(mockListDataStore.savedItemList!.name, exampleListName)
    }
    
    func testMediaArchivedOnAddingFirstMedia() {
        let endCursor = "endCursor"
        sut.addNewMedia(exampleMedia(withIDs: [1,2,3]), with: endCursor)
        XCTAssertNotNil(mockMediaDataStore.archivedMediaList)
        XCTAssertEqual(mockMediaDataStore.archivedMediaList!, exampleMedia(withIDs: [1,2,3]))
    }
    
    func testMediaArchivedOnAddingMoreNewMedia() {
        let endCursor = "endCursor"
        sut.addNewMedia(exampleMedia(withIDs: [4,5,6]), with: endCursor)
        XCTAssertEqual(mockMediaDataStore.archivedMediaList!, exampleMedia(withIDs: [4,5,6]))

        sut.addNewMedia(exampleMedia(withIDs: [1,2,3]), with: endCursor)
        XCTAssertEqual(mockMediaDataStore.archivedMediaList!, exampleMedia(withIDs: [1,2,3]))
    }
    
    func testMediaArchivedOnAppendingMoreMedia() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        
        sut.addNewMedia(exampleMedia(withIDs: [1,2,3]), with: endCursor1)
        XCTAssertEqual(mockMediaDataStore.archivedMediaList!, exampleMedia(withIDs: [1,2,3]))

        sut.appendMoreMedia(exampleMedia(withIDs: [4,5,6]), from: endCursor1, to: endCursor2)
        XCTAssertEqual(mockMediaDataStore.archivedMediaList!, exampleMedia(withIDs: [4,5,6]))
    }
    
    func testCanGetCountOfMediaAvailableBeforeFirstGap() {
        let endCursor1 = "endCursor"
        let endCursor2 = "endCursor"
        
        XCTAssertEqual(sut.itemCount, 0)
        
        sut.addNewMedia(exampleMedia(withIDs: [4,5,6]), with: endCursor2)
        sut.addNewMedia(exampleMedia(withIDs: [1,2,3]), with: endCursor1)
        
        XCTAssertEqual(sut.itemCount, 3)
    }
    
    func testCanGetCountOfMediaIDsAvailableBeforeFirstGap() {
        let endCursor1 = "endCursor"
        let endCursor2 = "endCursor"
        
        XCTAssertEqual(sut.itemIDsBeforeFirstGap, [])
        
        sut.addNewMedia(exampleMedia(withIDs: [4,5,6]), with: endCursor2)
        sut.addNewMedia(exampleMedia(withIDs: [1,2,3]), with: endCursor1)
        
        XCTAssertEqual(sut.itemIDsBeforeFirstGap, ["1","2","3"])
    }
    
    func testCanGetCountOfGappedListItemsAvailableBeforeFirstGap() {
        let endCursor1 = "endCursor"
        let endCursor2 = "endCursor"
        
        XCTAssertEqual(sut.listItemsBeforeFirstGap, [])
        
        sut.addNewMedia(exampleMedia(withIDs: [4,5,6]), with: endCursor2)
        sut.addNewMedia(exampleMedia(withIDs: [1,2,3]), with: endCursor1)
        
        XCTAssertEqual(sut.listItemsBeforeFirstGap, [GappedListItem(id: "1"),
                                                     GappedListItem(id: "2"),
                                                     GappedListItem(id: "3"),])
    }
    
    func testCanLoadMediaItemFromDataStore() {
        let exampleMediaItem = MediaItem(id: "123")
        mockMediaDataStore.mediaItemToLoad = exampleMediaItem
        
        let expectation = self.expectation(description: "Loaded media item")
        sut.mediaItem(for: "123") { (result) in
            XCTAssertEqual(result, exampleMediaItem)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 0.1)
    }
    
    func testCanLoadMultipleMediaItemsFromDataStore() {
        let exampleMediaItems = exampleMedia(withIDs: [1,2,3])
        mockMediaDataStore.mediaItemsToLoad = exampleMediaItems
        
        let expectation = self.expectation(description: "Loaded media item")
        sut.mediaItems(with: ["1","2","3"]) { (results) in
            XCTAssertEqual(results, exampleMediaItems)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 0.1)
    }
}
