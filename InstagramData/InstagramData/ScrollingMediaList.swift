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
    func scrollingMediaList(_ scrollingMediaList: ScrollingMediaList, removeCachedDataFor mediaItems: [MediaItem])
}

class ScrollingMediaList {
    
    private let mediaList: MediaList
    private let pageSize: Int
    
    private var firstPage: [MediaItem] = []
    private var secondPage: [MediaItem] = []
    private var middlePage: [MediaItem] = []
    private var fourthPage: [MediaItem] = []
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
    }
    
    func mediaItem(for id: String, completion: @escaping (MediaItem?) -> Void) {
        if let cachedMediaItem = mediaItemFromCache(for: id) {
            completion(cachedMediaItem)
        } else {
            mediaList.mediaItem(for: id, completion: completion)
        }
        
        DispatchQueue.global().async {
            self.populateBuffer(around: id)
        }
    }
    
    private func mediaItemFromCache(for id: String) -> MediaItem? {
        
        if let index = middlePage.index(where: { $0.id == id }) { // Media most likly to be in middle pages
            
            return middlePage[index]
            
        } else if let index = fourthPage.index(where: { $0.id == id }) {
            
            return fourthPage[index]
            
        } else if let index = secondPage.index(where: { $0.id == id }) {
            
            return secondPage[index]
            
        } else if let index = lastPage.index(where: { $0.id == id }) {
            
            return lastPage[index]
            
        } else if let index = firstPage.index(where: { $0.id == id }) {
            
            return firstPage[index]
            
        }
        
        return nil
    }
    
    func appendMoreMedia(_ newMedia: [MediaItem], from startCursor: String, to newEndCursor: String?) {
        mediaList.appendMoreMedia(newMedia, from: startCursor, to: newEndCursor)
    }
    
    func addNewMedia(_ newMedia: [MediaItem], with newEndCursor: String?) {
        mediaList.addNewMedia(newMedia, with: newEndCursor)
    }
    
    // TODO: need to synchronise reading and writing to the ivars
    private func populateBuffer(around id: String) {
        
        if middlePagesContainsMedia(with: id) {
            // Buffer already good 👍
            return
        }
        
        guard !populatingMedia else {
            return
        }
        populatingMedia = true
        
        if lastPage.contains(where: { $0.id == id }) {
            moveBufferUp()
        } else if firstPage.contains(where: { $0.id == id }) {
            moveBufferDown()
        } else {
            let index = listItemsBeforeFirstGap.index(where: { $0.id == id })!
            reloadAllBuffers(around: index)
        }
        
        populatingMedia = false
    }
    
    func middlePagesContainsMedia(with id: String) -> Bool {
        return (secondPage.contains(where: { $0.id == id }) ||
            middlePage.contains(where: { $0.id == id }) ||
            fourthPage.contains(where: { $0.id == id }))
    }
    
    private func moveBufferUp() {

        let cacheToRemove = firstPage + secondPage
        informDelegateToRemoveCachedMedia(cacheToRemove)

        firstPage = middlePage
        secondPage = fourthPage
        middlePage = lastPage
        
        if let id = middlePage.last?.id {
            let index = listItemsBeforeFirstGap.index(where: { $0.id == id })!
            fourthPage = loadListItemsForPage(startingFrom: index + 1)
            lastPage = loadListItemsForPage(startingFrom: index + 1 + pageSize)
            
            prefetchingDelegate?.scrollingMediaList(self, prefetchDataFor: fourthPage + lastPage)
            
            return
        }
        print("**** FAILED TO MOVE BUFFER UP ****")
    }
    
    func informDelegateToRemoveCachedMedia(_ cacheToRemove: [MediaItem]) {
        
        // Dont remove first page
        if cacheToRemove.contains(where: { ($0.id == self.mediaList.listItems.first?.id) }) {
            return
        }
        
        prefetchingDelegate?.scrollingMediaList(self, removeCachedDataFor: cacheToRemove)
    }
    
    private func moveBufferDown() {
        
        let cacheToRemove = fourthPage + lastPage
        informDelegateToRemoveCachedMedia(cacheToRemove)

        lastPage = middlePage
        fourthPage = secondPage
        middlePage = firstPage
        
        if let id = middlePage.first?.id {
            let index = listItemsBeforeFirstGap.index(where: { $0.id == id })!
            secondPage = loadListItemsForPage(startingFrom: index)
            firstPage = loadListItemsForPage(startingFrom: index - pageSize)
            
            prefetchingDelegate?.scrollingMediaList(self, prefetchDataFor: secondPage + firstPage)
            
            return
        }
        print("**** FAILED TO MOVE BUFFER DOWN ****")
    }
    
    private func reloadAllBuffers(around index: Int) {
        
        let cacheToRemove = firstPage + secondPage + middlePage + fourthPage + lastPage
        prefetchingDelegate?.scrollingMediaList(self, removeCachedDataFor: cacheToRemove)

        firstPage = loadListItemsForPage(before: index - pageSize)
        secondPage = loadListItemsForPage(before: index)
        middlePage = loadListItemsForPage(startingFrom: index)
        fourthPage = loadListItemsForPage(startingFrom: index + pageSize)
        lastPage = loadListItemsForPage(startingFrom: index + 2*pageSize)
        
        let mediaToPreload = firstPage + secondPage + middlePage + fourthPage + lastPage
        prefetchingDelegate?.scrollingMediaList(self, prefetchDataFor: mediaToPreload)
    }
    
    private func loadListItemsForPage(startingFrom index: Int) -> [MediaItem] {
        
        let totalNumberOfItems = listItemsBeforeFirstGap.count
        guard index < totalNumberOfItems && index >= 0 else {
            return []
        }
        
        let remainingMediaCount = totalNumberOfItems - index
        let numberOfItemsInPage = (remainingMediaCount > pageSize) ? pageSize : remainingMediaCount
        let finalIndex = index+numberOfItemsInPage
        
        let resultListItems = listItemsBeforeFirstGap[ index..<finalIndex ]

        return getMediaItemsSynchronously(for: resultListItems)
    }
    
    private func loadListItemsForPage(before index: Int) -> [MediaItem] {
        
        let totalNumberOfItems = listItemsBeforeFirstGap.count
        guard index < totalNumberOfItems && index >= 0 else {
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
        
        return result
    }
    
}
