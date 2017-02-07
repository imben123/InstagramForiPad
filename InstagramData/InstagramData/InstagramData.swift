//
//  InstagramData.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation

fileprivate class MediaDataStoreObserverDistribution: NSObject, MediaDataStoreObserver {
    
    func mediaDataStore(_ sender: MediaDataStore, didArchiveNewMedia newMedia: [MediaItem]) {
        InstagramData.shared.feedManager.mediaDataStore(sender, didArchiveNewMedia: newMedia)
    }
    
}

public class InstagramData {
    
    public static let shared: InstagramData = InstagramData()
    
    private let communicator: APICommunicator
    private let mediaDataStoreObserver: MediaDataStoreObserverDistribution
    private let mediaDataStore: MediaDataStore
    
    public let authManager: AuthManager
    public let feedManager: FeedManager
    public let likeReqestsManager: LikeReqestsManager
    public let mediaManager: MediaManager
    
    init() {
        communicator = APICommunicator()
        mediaDataStoreObserver = MediaDataStoreObserverDistribution()
        mediaDataStore = MediaDataStore()
        authManager = AuthManager(communicator: communicator)
        feedManager = FeedManager(communicator: communicator, mediaDataStore: mediaDataStore)
        likeReqestsManager = LikeReqestsManager(communicator: communicator, mediaDataStore: mediaDataStore)
        mediaManager = MediaManager(communicator: communicator, mediaDataStore: mediaDataStore)
        
        mediaDataStore.observer = mediaDataStoreObserver
    }
    
    public func createCommentsManager(for mediaItem: MediaItem) -> CommentsManager {
        return CommentsManager(mediaItem: mediaItem, communicator: communicator)
    }
    
}
