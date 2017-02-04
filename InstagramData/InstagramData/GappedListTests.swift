//
//  GappedListTests.swift
//  InstagramData
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import XCTest
@testable import InstagramData

class GappedListTests: XCTestCase {
    
    let exampleListName = "Test Name"
    var mockListDataStore: MockGappedListDataStore!
    var sut: GappedList!
    
    override func setUp() {
        super.setUp()
        mockListDataStore = MockGappedListDataStore()
        sut = GappedList(name: exampleListName, listDataStore: mockListDataStore)
    }
    
    func exampleIDs(in range: CountableRange<Int>) -> [String] {
        var result: [String] = []
        for i in range {
            result.append("\(i)")
        }
        return result
    }
    
    func exampleIDs(_ ids: [Int]) -> [String] {
        var result: [String] = []
        for id in ids {
            result.append("\(id)")
        }
        return result
    }
    
    func testItemListEmptyIfNoArchive() {
        XCTAssertEqual(sut.listItems.count, 0)
        XCTAssertNil(sut.firstGapCursor)
    }
    
    func testAddInitialItems() {
        let endCursor = "endCursor"
        let items = exampleIDs(in: 1..<4)
        sut.addNewItems(items, with: endCursor)
        
        let expectedListItems = [GappedListItem(id: "1"),
                                 GappedListItem(id: "2"),
                                 GappedListItem(id: "3"),
                                 GappedListItem(gapCursor: endCursor)]
        
        XCTAssertEqual(sut.listItems, expectedListItems)
        XCTAssertEqual(sut.firstGapCursor, endCursor)
    }
    
    func testAddOverlappingNewItems() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        sut.addNewItems(exampleIDs(in: 3..<6), with: endCursor1)
        sut.addNewItems(exampleIDs(in: 1..<4), with: endCursor2)

        
        let expectedListItems = [GappedListItem(id: "1"),
                                 GappedListItem(id: "2"),
                                 GappedListItem(id: "3"),
                                 GappedListItem(id: "4"),
                                 GappedListItem(id: "5"),
                                 GappedListItem(gapCursor: endCursor1)]
        
        XCTAssertEqual(sut.listItems, expectedListItems)
        XCTAssertEqual(sut.firstGapCursor, endCursor1)
    }
    
    func testCanGetitemCount() {
        let endCursor1 = "endCursor1"
        sut.addNewItems(exampleIDs(in: 3..<6), with: endCursor1)
        XCTAssertEqual(sut.itemCount, 3)
        
        let endCursor2 = "endCursor2"
        sut.addNewItems(exampleIDs(in: 1..<4), with: endCursor2)
        XCTAssertEqual(sut.itemCount, 5)
    }
    
    func testAddingNonOverlappingNewItemsLeavesGap() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        
        sut.addNewItems(exampleIDs(in: 5..<8), with: endCursor1)
        sut.addNewItems(exampleIDs(in: 1..<4), with: endCursor2)
        
        let expectedListItems = [GappedListItem(id: "1"),
                                 GappedListItem(id: "2"),
                                 GappedListItem(id: "3"),
                                 GappedListItem(gapCursor: endCursor2),
                                 GappedListItem(id: "5"),
                                 GappedListItem(id: "6"),
                                 GappedListItem(id: "7"),
                                 GappedListItem(gapCursor: endCursor1)
        ]
        
        XCTAssertEqual(sut.listItems, expectedListItems)
    }
    
    func testCanGetItemListBeforeFirstGap() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        
        sut.addNewItems(exampleIDs(in: 5..<8), with: endCursor1)
        sut.addNewItems(exampleIDs(in: 1..<4), with: endCursor2)
        
        let expectedListItems = [GappedListItem(id: "1"),
                                 GappedListItem(id: "2"),
                                 GappedListItem(id: "3")]
        XCTAssertEqual(sut.listItemsBeforeFirstGap, expectedListItems)
    }
    
    func testAppendingMoreItemsDoesNotLeaveGap() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        
        sut.addNewItems(exampleIDs(in: 1..<4), with: endCursor1)
        sut.appendMoreItems(exampleIDs(in: 4..<7), from: endCursor1, to: endCursor2)
        
        
        let expectedListItems = [GappedListItem(id: "1"),
                                 GappedListItem(id: "2"),
                                 GappedListItem(id: "3"),
                                 GappedListItem(id: "4"),
                                 GappedListItem(id: "5"),
                                 GappedListItem(id: "6"),
                                 GappedListItem(gapCursor: endCursor2)]
        
        XCTAssertEqual(sut.listItems, expectedListItems)
    }
    
    func testFillingGapInItemsWithoutOverlap() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        let endCursor3 = "endCursor3"
        
        sut.addNewItems(exampleIDs(in: 8..<10), with: endCursor1)
        sut.addNewItems(exampleIDs(in: 1..<4), with: endCursor2)
        sut.appendMoreItems(exampleIDs(in: 4..<7), from: endCursor2, to: endCursor3)
        
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
    
    func testFillingGapInItemsWithOverlapDoesNotLeaveGap() {
        let endCursor1 = "endCursor1"
        let endCursor2 = "endCursor2"
        let endCursor3 = "endCursor3"
        
        sut.addNewItems(exampleIDs([8,9]), with: endCursor1)
        sut.addNewItems(exampleIDs([1,2,3]), with: endCursor2)
        sut.appendMoreItems(exampleIDs([4,5,6,7,8]), from: endCursor2, to: endCursor3)
        
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
    
    // MARK: - archiving
    
    func testItemListArchivedOnAddingFirstItems() {
        let endCursor = "endCursor"
        
        sut.addNewItems(exampleIDs([1,2,3]), with: endCursor)
        let expectedListItems = [GappedListItem(id: "1"),
                                 GappedListItem(id: "2"),
                                 GappedListItem(id: "3"),
                                 GappedListItem(gapCursor: endCursor)]
        
        XCTAssertNotNil(mockListDataStore.savedItemList)
        XCTAssertEqual(mockListDataStore.savedItemList!.listItems, expectedListItems)
        XCTAssertEqual(mockListDataStore.savedItemList!.name, exampleListName)
    }
    
    func testItemListArchivedOnAddingAddingMoreNewItems() {
        let endCursor1 = "endCursor"
        let endCursor2 = "endCursor"
        
        sut.addNewItems(exampleIDs([4,5,6]), with: endCursor2)
        sut.addNewItems(exampleIDs([1,2,3]), with: endCursor1)
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
    
    func testItemListArchivedOnAppendingMoreItems() {
        let endCursor1 = "endCursor"
        let endCursor2 = "endCursor"
        
        sut.addNewItems(exampleIDs([1,2,3]), with: endCursor1)
        sut.appendMoreItems(exampleIDs([4,5,6]), from: endCursor1, to: endCursor2)
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
    
    func testCanGetCountOfItemsAvailableBeforeFirstGap() {
        let endCursor1 = "endCursor"
        let endCursor2 = "endCursor"
        
        XCTAssertEqual(sut.itemCount, 0)
        
        sut.addNewItems(exampleIDs([4,5,6]), with: endCursor2)
        sut.addNewItems(exampleIDs([1,2,3]), with: endCursor1)
        
        XCTAssertEqual(sut.itemCount, 3)
    }
    
    func testCanGetCountOfItemsIDsAvailableBeforeFirstGap() {
        let endCursor1 = "endCursor"
        let endCursor2 = "endCursor"
        
        XCTAssertEqual(sut.itemIDsBeforeFirstGap, [])
        
        sut.addNewItems(exampleIDs([4,5,6]), with: endCursor2)
        sut.addNewItems(exampleIDs([1,2,3]), with: endCursor1)
        
        XCTAssertEqual(sut.itemIDsBeforeFirstGap, ["1","2","3"])
    }
    
    func testCanGetCountOfGappedListItemsAvailableBeforeFirstGap() {
        let endCursor1 = "endCursor"
        let endCursor2 = "endCursor"
        
        XCTAssertEqual(sut.listItemsBeforeFirstGap, [])
        
        sut.addNewItems(exampleIDs([4,5,6]), with: endCursor2)
        sut.addNewItems(exampleIDs([1,2,3]), with: endCursor1)
        
        XCTAssertEqual(sut.listItemsBeforeFirstGap, [GappedListItem(id: "1"),
                                                     GappedListItem(id: "2"),
                                                     GappedListItem(id: "3"),])
    }
}
