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
    
    var mockDataStore: MockMediaListDataStore!
    var sut: MediaList!
    
    let exampleMedia1 = [ MediaItem(id: "4"),  MediaItem(id: "5"),  MediaItem(id: "6")]
    let exampleMedia2 = [ MediaItem(id: "7"),  MediaItem(id: "8"),  MediaItem(id: "9")]
    let exampleMediaOverlap = [ MediaItem(id: "1"),  MediaItem(id: "2"),  MediaItem(id: "3"),  MediaItem(id: "4")]
    let exampleMediaCombined = [ MediaItem(id: "1"),  MediaItem(id: "2"),  MediaItem(id: "3"),  MediaItem(id: "4"),
                                MediaItem(id: "5"),  MediaItem(id: "6")]
    
    override func setUp() {
        super.setUp()
        mockDataStore = MockMediaListDataStore(mediaOrigin: "mediaOrigin")
        sut = MediaList(dataStore: mockDataStore)
    }
    
    func testMediaListEmptyIfNoArchive() {
        XCTAssertEqual(sut.media, [])
        XCTAssertNil(sut.endCursor)
    }
    
    func testAddInitialMedia() {
        let endCursor = "endCursor"
        sut.addNewMedia(exampleMedia1, with: endCursor)
        XCTAssertEqual(sut.media, exampleMedia1)
        XCTAssertEqual(sut.endCursor, endCursor)
    }
    
    func testAddMoreMedia() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        sut.addNewMedia(exampleMedia1, with: endCursor1)
        sut.appendMoreMedia(exampleMedia2, from: endCursor1, to: endCursor2)
        XCTAssertEqual(sut.media, exampleMedia1 + exampleMedia2)
        XCTAssertEqual(sut.endCursor, endCursor2)
    }
    
    func testAddNewMedia() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        sut.addNewMedia(exampleMedia1, with: endCursor1)
        sut.addNewMedia(exampleMediaOverlap, with: endCursor2)
        XCTAssertEqual(sut.media, exampleMediaCombined)
        XCTAssertEqual(sut.endCursor, endCursor1)
    }
    
    func testAddingNonOverlappingNewMediaReplacesOldMedia() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        sut.addNewMedia(exampleMedia1, with: endCursor1)
        sut.addNewMedia(exampleMedia2, with: endCursor2)
        XCTAssertEqual(sut.media, exampleMedia2)
        XCTAssertEqual(sut.endCursor, endCursor2)
    }
    
    func testMediaUnarchivedOnLaunch() {
        let endCursor = "endCursor"
        mockDataStore.archivedMediaList = (exampleMedia1, endCursor)
        sut = MediaList(dataStore: mockDataStore)
        XCTAssertEqual(sut.media, exampleMedia1)
        XCTAssertEqual(sut.endCursor, endCursor)
    }
    
    func testMediaArchivedOnNewMedia() {
        let endCursor = "endCursor"
        sut.addNewMedia(exampleMedia1, with: endCursor)
        XCTAssertNotNil(mockDataStore.archivedMediaList)
        XCTAssertEqual(mockDataStore.archivedMediaList!.media, sut.media)
        XCTAssertEqual(mockDataStore.archivedMediaList!.endCursor, sut.endCursor)
    }
    
    func testMediaArchivedOnMoreMedia() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        sut.addNewMedia(exampleMedia1, with: endCursor1)
        sut.appendMoreMedia(exampleMedia2, from: endCursor1, to: endCursor2)
        XCTAssertNotNil(mockDataStore.archivedMediaList)
        XCTAssertEqual(mockDataStore.archivedMediaList!.media, sut.media)
        XCTAssertEqual(mockDataStore.archivedMediaList!.endCursor, sut.endCursor)
    }
}
