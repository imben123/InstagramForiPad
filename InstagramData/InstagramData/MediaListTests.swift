//
//  MediaListTests.swift
//  InstagramData
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import XCTest
@testable import InstagramData

extension MediaItem {
    init(id: String) {
        self.id = id
        self.date = Date(timeIntervalSince1970: 0)
        self.dimensions = CGSize.zero
        self.ownerId = ""
        self.code = nil
        self.isVideo = false
        self.thumbnail = nil
        self.display = URL(string: "http://google.com")!
        self.commentsDisabled = false
        self.commentsCount = 0
        self.likesCount = 0
    }
}

class MediaListTests: XCTestCase {
    
    let exampleListName = "Test Name"
    var mockMediaDataStore: MockMediaDataStore!
    var mockListDataStore: MockMediaListDataStore!
    var sut: MediaList!
    
    override func setUp() {
        super.setUp()
        mockMediaDataStore = MockMediaDataStore(mediaOrigin: "mediaOrigin")
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
    
    func exampleMedia(withIDs ids: [Int]) -> [MediaItem] {
        var result: [MediaItem] = []
        for id in ids {
            result.append(MediaItem(id: "\(id)"))
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
        XCTAssertEqual(sut.media, media)
        XCTAssertEqual(sut.firstGapCursor, endCursor)
    }
    
    func testAddOverlappingNewMedia() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        sut.addNewMedia(exampleMediaWithIDs(in: 3..<6), with: endCursor1)
        sut.addNewMedia(exampleMediaWithIDs(in: 1..<4), with: endCursor2)
        XCTAssertEqual(sut.media, exampleMediaWithIDs(in: 1..<6))
        XCTAssertEqual(sut.firstGapCursor, endCursor1)
    }
    
    func testAddOverlappingNewMediaDoesNotLeaveGap() {
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
    
    func testMediaAfterGapNotReturned() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        
        sut.addNewMedia(exampleMediaWithIDs(in: 5..<8), with: endCursor1)
        sut.addNewMedia(exampleMediaWithIDs(in: 1..<4), with: endCursor2)
        
        XCTAssertEqual(sut.media, exampleMedia(withIDs: [1,2,3]))
        XCTAssertEqual(sut.firstGapCursor, endCursor2)
    }
    
    func testAppendingMoreMedia() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        
        sut.addNewMedia(exampleMediaWithIDs(in: 1..<4), with: endCursor1)
        sut.appendMoreMedia(exampleMediaWithIDs(in: 4..<7), from: endCursor1, to: endCursor2)
        
        XCTAssertEqual(sut.media, exampleMediaWithIDs(in: 1..<4) + exampleMediaWithIDs(in: 4..<7))
        XCTAssertEqual(sut.firstGapCursor, endCursor2)
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
    
    func testMediaUnarchivedOnLaunch() {
        let endCursor = "endCursor"
        mockMediaDataStore.archivedMediaList = exampleMedia(withIDs: [1,2,3])
        mockListDataStore.savedMediaList = ([MediaListItem(id: "1"),
                                             MediaListItem(id: "2"),
                                             MediaListItem(id: "3"),
                                             MediaListItem(gapCursor: endCursor)], exampleListName)
        sut = MediaList(name: exampleListName, mediaDataStore: mockMediaDataStore, listDataStore: mockListDataStore)
        XCTAssertEqual(sut.media, exampleMedia(withIDs: [1,2,3]))
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
        XCTAssertEqual(mockMediaDataStore.archivedMediaList!, sut.media)
    }
    
    func testMediaArchivedOnAddingMoreNewMedia() {
        let endCursor = "endCursor"
        sut.addNewMedia(exampleMedia(withIDs: [4,5,6]), with: endCursor)
        sut.addNewMedia(exampleMedia(withIDs: [1,2,3]), with: endCursor)
        XCTAssertNotNil(mockMediaDataStore.archivedMediaList)
        XCTAssertEqual(mockMediaDataStore.archivedMediaList!, exampleMedia(withIDs: [4,5,6,1,2,3]))
    }
    
    func testMediaArchivedOnAppendingMoreMedia() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        sut.addNewMedia(exampleMedia(withIDs: [1,2,3]), with: endCursor1)
        sut.appendMoreMedia(exampleMedia(withIDs: [4,5,6]), from: endCursor1, to: endCursor2)
        XCTAssertNotNil(mockMediaDataStore.archivedMediaList)
        XCTAssertEqual(mockMediaDataStore.archivedMediaList!, exampleMedia(withIDs: [1,2,3,4,5,6]))
    }
}
