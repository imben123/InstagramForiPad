//
//  InstagramData.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
import SDWebImage
import RealmSwift

fileprivate class MediaDataStoreObserverDistribution: NSObject, MediaDataStoreObserver {
    
    func mediaDataStore(_ sender: MediaDataStore, didArchiveNewMedia newMedia: [MediaItem]) {
        InstagramData.shared.userFeedMediaFeed.mediaDataStore(sender, didArchiveNewMedia: newMedia)
    }
    
}

public class InstagramData {
    
    public static let shared: InstagramData = InstagramData()
    
    private let communicator: APICommunicator
    public let usersDataStore: UsersDataStore
    private let mediaDataStoreObserver: MediaDataStoreObserverDistribution
    private let mediaDataStore: MediaDataStore
    
    public let authManager: AuthManager
    public let userFeedMediaFeed: FeedManager
    public let likeReqestsManager: LikeReqestsManager
    public let followRequestsManager: FollowRequestsManager
    public let mediaManager: MediaManager
    
    init() {
        communicator = APICommunicator()
        mediaDataStoreObserver = MediaDataStoreObserverDistribution()
        mediaDataStore = MediaDataStore()
        usersDataStore = UsersDataStore(communicator: communicator)
        authManager = AuthManager(communicator: communicator)
        userFeedMediaFeed = FeedManager(communicator: communicator, mediaDataStore: mediaDataStore)
        likeReqestsManager = LikeReqestsManager(communicator: communicator, mediaDataStore: mediaDataStore)
        followRequestsManager = FollowRequestsManager(communicator: communicator)
        mediaManager = MediaManager(communicator: communicator, mediaDataStore: mediaDataStore)
        
        mediaDataStore.observer = mediaDataStoreObserver
    }
    
    public func createCommentsManager(for mediaItem: MediaItem) -> CommentsManager {
        return CommentsManager(mediaItem: mediaItem, communicator: communicator)
    }
    
    public func createUserProfileMediaFeed(for user: User) -> UserProfileMediaFeed {
        return UserProfileMediaFeed(user: user, 
                                    communicator: communicator,
                                    mediaDataStore: mediaDataStore)
    }
    
    public func logout() {
        authManager.logout()
        SDImageCache.shared.clearDisk()
        try! Realm().write { try! Realm().deleteAll() }
    }
    
}
