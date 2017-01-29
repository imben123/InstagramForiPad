//
//  MediaListTests.swift
//  InstagramData
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import XCTest
@testable import InstagramData

extension User {
    init(id: String) {
        self.id = id
        self.profilePictureURL = URL(string: "https://google.com")!
        self.fullName = "Full name"
        self.username = "username"
        self.biography = "This is a user biography"
        self.externalURL = URL(string: "https://google.com")!
        self.media = []
        self.totalNumberOfMediaItems = 0
    }
}

extension MediaItem {
    init(id: String) {
        self.id = id
        self.date = Date(timeIntervalSince1970: 0)
        self.dimensions = CGSize.zero
        self.owner = User(id: "123")
        self.code = nil
        self.isVideo = false
        self.display = URL(string: "https://google.com")!
        self.thumbnail = display
        self.commentsDisabled = false
        self.commentsCount = 0
        self.likesCount = 0
        self.viewerHasLiked = false
    }
}

class MediaListTests: XCTestCase {
    
    let exampleListName = "Test Name"
    var mockMediaDataStore: MockMediaDataStore!
    var mockListDataStore: MockMediaListDataStore!
    var sut: MediaList!
    
    override func setUp() {
        super.setUp()
        mockMediaDataStore = MockMediaDataStore()
        mockListDataStore = MockMediaListDataStore()
        sut = MediaList(name: exampleListName, mediaDataStore: mockMediaDataStore, listDataStore: mockListDataStore)
    }
    
    func exampleMediaWithIDs(in range: CountableRange<Int>) -> [MediaItem] {
        var result: [MediaItem] = []
        for i in range {
            result.append(MediaItem(id: "\(i)"))
        }
        return result
    }
    
    func exampleMediaListWithIDs(in range: CountableRange<Int>) -> [MediaListItem] {
        var result: [MediaListItem] = []
        for i in range {
            result.append(MediaListItem(id: "\(i)"))
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
    
    func exampleMediaList(withIDs ids: [Int]) -> [MediaListItem] {
        var result: [MediaListItem] = []
        for id in ids {
            result.append(MediaListItem(id: "\(id)"))
        }
        return result
    }
    
    func testMediaListEmptyIfNoArchive() {
        XCTAssertEqual(sut.listItems.count, 0)
        XCTAssertNil(sut.firstGapCursor)
    }
    
    func testAddInitialMedia() {
        let endCursor = "endCursor"
        let media = exampleMediaWithIDs(in: 1..<4)
        sut.addNewMedia(media, with: endCursor)
        
        let expectedListItems = [MediaListItem(id: "1"),
                                 MediaListItem(id: "2"),
                                 MediaListItem(id: "3"),
                                 MediaListItem(gapCursor: endCursor)]
        
        XCTAssertEqual(sut.listItems, expectedListItems)
        XCTAssertEqual(sut.firstGapCursor, endCursor)
    }
    
    func testAddOverlappingNewMedia() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        sut.addNewMedia(exampleMediaWithIDs(in: 3..<6), with: endCursor1)
        sut.addNewMedia(exampleMediaWithIDs(in: 1..<4), with: endCursor2)

        
        let expectedListItems = [MediaListItem(id: "1"),
                                 MediaListItem(id: "2"),
                                 MediaListItem(id: "3"),
                                 MediaListItem(id: "4"),
                                 MediaListItem(id: "5"),
                                 MediaListItem(gapCursor: endCursor1)]
        
        XCTAssertEqual(sut.listItems, expectedListItems)
        XCTAssertEqual(sut.firstGapCursor, endCursor1)
    }
    
    func testCanGetMediaCount() {
        let endCursor1 = "endCursor1"
        sut.addNewMedia(exampleMediaWithIDs(in: 3..<6), with: endCursor1)
        XCTAssertEqual(sut.mediaCount, 3)
        
        let endCursor2 = "endCursor2"
        sut.addNewMedia(exampleMediaWithIDs(in: 1..<4), with: endCursor2)
        XCTAssertEqual(sut.mediaCount, 5)
    }
    
    func testAddingNonOverlappingNewMediaLeavesGap() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        
        sut.addNewMedia(exampleMediaWithIDs(in: 5..<8), with: endCursor1)
        sut.addNewMedia(exampleMediaWithIDs(in: 1..<4), with: endCursor2)
        
        let expectedListItems = [MediaListItem(id: "1"),
                                 MediaListItem(id: "2"),
                                 MediaListItem(id: "3"),
                                 MediaListItem(gapCursor: endCursor2),
                                 MediaListItem(id: "5"),
                                 MediaListItem(id: "6"),
                                 MediaListItem(id: "7"),
                                 MediaListItem(gapCursor: endCursor1)
        ]
        
        XCTAssertEqual(sut.listItems, expectedListItems)
    }
    
    func testCanGetMediaListBeforeFirstGap() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        
        sut.addNewMedia(exampleMediaWithIDs(in: 5..<8), with: endCursor1)
        sut.addNewMedia(exampleMediaWithIDs(in: 1..<4), with: endCursor2)
        
        let expectedListItems = [MediaListItem(id: "1"),
                                 MediaListItem(id: "2"),
                                 MediaListItem(id: "3")]
        XCTAssertEqual(sut.listItemsBeforeFirstGap, expectedListItems)
    }
    
    func testAppendingMoreMediaDoesNotLeaveGap() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        
        sut.addNewMedia(exampleMediaWithIDs(in: 1..<4), with: endCursor1)
        sut.appendMoreMedia(exampleMediaWithIDs(in: 4..<7), from: endCursor1, to: endCursor2)
        
        
        let expectedListItems = [MediaListItem(id: "1"),
                                 MediaListItem(id: "2"),
                                 MediaListItem(id: "3"),
                                 MediaListItem(id: "4"),
                                 MediaListItem(id: "5"),
                                 MediaListItem(id: "6"),
                                 MediaListItem(gapCursor: endCursor2)]
        
        XCTAssertEqual(sut.listItems, expectedListItems)
    }
    
    func testFillingGapInMediaWithoutOverlap() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        let endCursor3 = "endCursor3"
        
        sut.addNewMedia(exampleMediaWithIDs(in: 8..<10), with: endCursor1)
        sut.addNewMedia(exampleMediaWithIDs(in: 1..<4), with: endCursor2)
        sut.appendMoreMedia(exampleMediaWithIDs(in: 4..<7), from: endCursor2, to: endCursor3)
        
        let expectedListItems = [MediaListItem(id: "1"),
                                 MediaListItem(id: "2"),
                                 MediaListItem(id: "3"),
                                 MediaListItem(id: "4"),
                                 MediaListItem(id: "5"),
                                 MediaListItem(id: "6"),
                                 MediaListItem(gapCursor: endCursor3),
                                 MediaListItem(id: "8"),
                                 MediaListItem(id: "9"),
                                 MediaListItem(gapCursor: endCursor1)]
        
        XCTAssertEqual(sut.listItems, expectedListItems)
        
    }
    
    func testFillingGapInMediaWithOverlapDoesNotLeaveGap() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        let endCursor3 = "endCursor3"
        
        sut.addNewMedia(exampleMedia(withIDs: [8,9]), with: endCursor1)
        sut.addNewMedia(exampleMedia(withIDs: [1,2,3]), with: endCursor2)
        sut.appendMoreMedia(exampleMedia(withIDs: [4,5,6,7,8]), from: endCursor2, to: endCursor3)
        
        let expectedListItems = [MediaListItem(id: "1"),
                                 MediaListItem(id: "2"),
                                 MediaListItem(id: "3"),
                                 MediaListItem(id: "4"),
                                 MediaListItem(id: "5"),
                                 MediaListItem(id: "6"),
                                 MediaListItem(id: "7"),
                                 MediaListItem(id: "8"),
                                 MediaListItem(id: "9"),
                                 MediaListItem(gapCursor: endCursor1)]
        
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
        mockListDataStore.savedMediaList = ([MediaListItem(id: "1"),
                                             MediaListItem(id: "2"),
                                             MediaListItem(id: "3"),
                                             MediaListItem(gapCursor: endCursor)], exampleListName)
        sut = MediaList(name: exampleListName, mediaDataStore: mockMediaDataStore, listDataStore: mockListDataStore)
        XCTAssertEqual(sut.listItems, mockListDataStore.savedMediaList!.listItems)
    }
    
    func testMediaListArchivedOnAddingFirstMedia() {
        let endCursor = "endCursor"
        
        sut.addNewMedia(exampleMedia(withIDs: [1,2,3]), with: endCursor)
        let expectedListItems = [MediaListItem(id: "1"),
                                 MediaListItem(id: "2"),
                                 MediaListItem(id: "3"),
                                 MediaListItem(gapCursor: endCursor)]
        
        XCTAssertNotNil(mockListDataStore.savedMediaList)
        XCTAssertEqual(mockListDataStore.savedMediaList!.listItems, expectedListItems)
        XCTAssertEqual(mockListDataStore.savedMediaList!.name, exampleListName)
    }
    
    func testMediaListArchivedOnAddingAddingMoreNewMedia() {
        let endCursor1 = "endCursor"
        let endCursor2 = "endCursor"
        
        sut.addNewMedia(exampleMedia(withIDs: [4,5,6]), with: endCursor2)
        sut.addNewMedia(exampleMedia(withIDs: [1,2,3]), with: endCursor1)
        let expectedListItems = [MediaListItem(id: "1"),
                                 MediaListItem(id: "2"),
                                 MediaListItem(id: "3"),
                                 MediaListItem(gapCursor: endCursor1),
                                 MediaListItem(id: "4"),
                                 MediaListItem(id: "5"),
                                 MediaListItem(id: "6"),
                                 MediaListItem(gapCursor: endCursor2)]
        
        XCTAssertNotNil(mockListDataStore.savedMediaList)
        XCTAssertEqual(mockListDataStore.savedMediaList!.listItems, expectedListItems)
        XCTAssertEqual(mockListDataStore.savedMediaList!.name, exampleListName)
    }
    
    func testMediaListArchivedOnAppendingMoreMedia() {
        let endCursor1 = "endCursor"
        let endCursor2 = "endCursor"
        
        sut.addNewMedia(exampleMedia(withIDs: [1,2,3]), with: endCursor1)
        sut.appendMoreMedia(exampleMedia(withIDs: [4,5,6]), from: endCursor1, to: endCursor2)
        let expectedListItems = [MediaListItem(id: "1"),
                                 MediaListItem(id: "2"),
                                 MediaListItem(id: "3"),
                                 MediaListItem(id: "4"),
                                 MediaListItem(id: "5"),
                                 MediaListItem(id: "6"),
                                 MediaListItem(gapCursor: endCursor2)]
        
        XCTAssertNotNil(mockListDataStore.savedMediaList)
        XCTAssertEqual(mockListDataStore.savedMediaList!.listItems, expectedListItems)
        XCTAssertEqual(mockListDataStore.savedMediaList!.name, exampleListName)
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
        
        XCTAssertEqual(sut.mediaCount, 0)
        
        sut.addNewMedia(exampleMedia(withIDs: [4,5,6]), with: endCursor2)
        sut.addNewMedia(exampleMedia(withIDs: [1,2,3]), with: endCursor1)
        
        XCTAssertEqual(sut.mediaCount, 3)
    }
    
    func testCanGetCountOfMediaIDsAvailableBeforeFirstGap() {
        let endCursor1 = "endCursor"
        let endCursor2 = "endCursor"
        
        XCTAssertEqual(sut.mediaIDsBeforeFirstGap, [])
        
        sut.addNewMedia(exampleMedia(withIDs: [4,5,6]), with: endCursor2)
        sut.addNewMedia(exampleMedia(withIDs: [1,2,3]), with: endCursor1)
        
        XCTAssertEqual(sut.mediaIDsBeforeFirstGap, ["1","2","3"])
    }
    
    func testCanGetCountOfMediaListItemsAvailableBeforeFirstGap() {
        let endCursor1 = "endCursor"
        let endCursor2 = "endCursor"
        
        XCTAssertEqual(sut.listItemsBeforeFirstGap, [])
        
        sut.addNewMedia(exampleMedia(withIDs: [4,5,6]), with: endCursor2)
        sut.addNewMedia(exampleMedia(withIDs: [1,2,3]), with: endCursor1)
        
        XCTAssertEqual(sut.listItemsBeforeFirstGap, [MediaListItem(id: "1"),
                                                     MediaListItem(id: "2"),
                                                     MediaListItem(id: "3"),])
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
