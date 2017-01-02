//
//  ScrollingMediaList.swift
//  InstagramData
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation

// Should possibly test this independantly... It's currently tested through FeedManagerTests

protocol ScrollingMediaListPrefetchingDelegate: class {
    func scrollingMediaList(_ scrollingMediaList: ScrollingMediaList, prefetchDataFor mediaItems: [MediaItem])
}

class ScrollingMediaList {
    
    private let mediaList: MediaList
    private let pageSize: Int
    
    private var firstPage: [MediaItem] = []
    private var middlePage: [MediaItem] = []
    private var lastPage: [MediaItem] = []
    private var populatingMedia = false
    
    weak var prefetchingDelegate: ScrollingMediaListPrefetchingDelegate? = nil
    
    var listItems: [MediaListItem] {
        return mediaList.listItems
    }
    
    var firstGapCursor: String? {
        return mediaList.firstGapCursor
    }
    
    var listItemsBeforeFirstGap: [MediaListItem] {
        return mediaList.listItemsBeforeFirstGap
    }
    
    var mediaIDsBeforeFirstGap: [String] {
        return mediaList.mediaIDsBeforeFirstGap
    }
    
    var mediaCount: Int {
        return mediaList.mediaCount
    }
    
    init(name: String, pageSize: Int, mediaDataStore: MediaDataStore, listDataStore: MediaListDataStore) {
        self.mediaList = MediaList(name: name, mediaDataStore: mediaDataStore, listDataStore: listDataStore)
        self.pageSize = pageSize
        
        if let id = self.mediaList.listItemsBeforeFirstGap.first?.id {
            DispatchQueue.global().async {
                self.populateBuffer(around: id)
            }
        }
    }
    
    func mediaItem(for id: String, completion: @escaping (MediaItem?) -> Void) {
        if let cachedMediaItem = mediaItemFromCache(for: id) {
            print("Got media from cache")
            completion(cachedMediaItem)
        } else {
            print("Media not in cache")
            mediaList.mediaItem(for: id, completion: completion)
        }
        
        DispatchQueue.global().async {
            self.populateBuffer(around: id)
        }
    }
    
    private func mediaItemFromCache(for id: String) -> MediaItem? {
        
        if let index = middlePage.index(where: { $0.id == id }) { // Media most likly to be in middle page
            
            return middlePage[index]
            
        } else if let index = lastPage.index(where: { $0.id == id }) {
            
            return lastPage[index]
            
        } else if let index = firstPage.index(where: { $0.id == id }) {
            
            return firstPage[index]
            
        }
        
        return nil
    }
    
    func appendMoreMedia(_ newMedia: [MediaItem], from startCursor: String, to newEndCursor: String) {
        mediaList.appendMoreMedia(newMedia, from: startCursor, to: newEndCursor)
    }
    
    func addNewMedia(_ newMedia: [MediaItem], with newEndCursor: String) {
        mediaList.addNewMedia(newMedia, with: newEndCursor)
    }
    
    // TODO: need to synchronise reading and writing to the ivars
    private func populateBuffer(around id: String) {
        
        if middlePage.contains(where: { $0.id == id }) {
            // Buffer already good 👍
            return
        }
        
        guard !populatingMedia else {
            return
        }
        populatingMedia = true
        
        print("---- Need to update media cache buffer")
        
        if lastPage.contains(where: { $0.id == id }) {
            
            moveBufferUp()
            
        } else if firstPage.contains(where: { $0.id == id }) {
            
            moveBufferDown()
            
        } else {
            
            let index = listItemsBeforeFirstGap.index(where: { $0.id == id })!
            firstPage = loadListItemsForPage(before: index)
            middlePage = loadListItemsForPage(startingFrom: index)
            lastPage = loadListItemsForPage(startingFrom: index + pageSize)
            
            print("====== Reset buffer to... \(index-pageSize)-\(index+pageSize*2)")
        }
        
        populatingMedia = false
    }
    
    private func moveBufferUp() {
        firstPage = middlePage
        middlePage = lastPage
        
        if let id = middlePage.last?.id {
            let index = listItemsBeforeFirstGap.index(where: { $0.id == id })!
            lastPage = loadListItemsForPage(startingFrom: index + 1)
            print("====== Reset buffer to... \(index-pageSize)-\(index+pageSize*2)")
            return
        }
        print("**** FAILED TO MOVE BUFFER UP ****")
    }
    
    private func moveBufferDown() {
        lastPage = middlePage
        middlePage = firstPage
        
        if let id = middlePage.first?.id {
            let index = listItemsBeforeFirstGap.index(where: { $0.id == id })!
            firstPage = loadListItemsForPage(startingFrom: index)
            print("====== Reset buffer to... \(index-pageSize)-\(index+pageSize*2)")
            return
        }
        print("**** FAILED TO MOVE BUFFER DOWN ****")
    }
    
    private func loadListItemsForPage(startingFrom index: Int) -> [MediaItem] {
        
        let totalNumberOfItems = listItemsBeforeFirstGap.count
        guard index < totalNumberOfItems else {
            return []
        }
        
        let remainingMediaCount = totalNumberOfItems - index
        let numberOfItemsInPage = (remainingMediaCount > pageSize) ? pageSize : remainingMediaCount
        let finalIndex = index+numberOfItemsInPage
        
        let resultListItems = listItemsBeforeFirstGap[ index..<finalIndex ]

        return getMediaItemsSynchronously(for: resultListItems)
    }
    
    private func loadListItemsForPage(before index: Int) -> [MediaItem] {
        
        guard index >= 0 else {
            return []
        }
        
        let numberOfItemsInPage = (index > pageSize) ? pageSize : index
        let firstIndex = index-numberOfItemsInPage
        
        let resultListItems = listItemsBeforeFirstGap[ firstIndex..<index ]
        
        return getMediaItemsSynchronously(for: resultListItems)
    }
    
    private func getMediaItemsSynchronously(for listItems: ArraySlice<MediaListItem>) -> [MediaItem] {
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: [MediaItem]! = nil
        let ids = listItems.map({ $0.id! })
        mediaList.mediaItems(with: ids) { (mediaItems) in
            result = mediaItems
            semaphore.signal()
        }
        semaphore.wait()
        
        prefetchingDelegate?.scrollingMediaList(self, prefetchDataFor: result)
        return result
    }
    
}
