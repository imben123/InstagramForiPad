//
//  LikeReqestsManager.swift
//  InstagramData
//
//  Created by Ben Davis on 28/01/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import Foundation
import SwiftToolbox
import Reachability

public class LikeReqestsManager {
    
    let communicator: APICommunicator
    let mediaDataStore: MediaDataStore
    let reliableNetworkTaskManager: ReliableNetworkTaskManager
    var pendingTasks: [String:Bool] = [:] // Map of id's to like/unlike request
    
    init(communicator: APICommunicator, reliableNetworkTaskManager: ReliableNetworkTaskManager) {
        self.communicator = communicator
        self.reliableNetworkTaskManager = reliableNetworkTaskManager
        self.mediaDataStore = MediaDataStore()
    }
    
    convenience init(communicator: APICommunicator) {
        let queue = DispatchQueue(label: "LikeReqestsManagerQueue")
        let taskDispatcher = TaskDispatcher(queue: queue)
        let reachability = Reachability(hostName: "instagram.com")!
        let reliableNetworkTaskManager = ReliableNetworkTaskManager(reachability: reachability,
                                                                    taskDispatcher: taskDispatcher)
        self.init(communicator: communicator, reliableNetworkTaskManager: reliableNetworkTaskManager)
    }
    
    public func likePost(with id: String) {
        
        pendingTasks[id] = true
        
        reliableNetworkTaskManager.performTask { (failure) in
            
            guard self.pendingTasks[id] == true else {
                return
            }
            
            let response = self.communicator.likePost(with: id)
            guard response.succeeded else {
                return failure()
            }
            
            self.pendingTasks.removeValue(forKey: id)
            
            self.mediaDataStore.loadMediaItem(with: id, completion: { (mediaItem) in
                if let mediaItem = mediaItem {
                    var mediaItem = mediaItem
                    mediaItem.viewerHasLiked = true
                    self.mediaDataStore.archiveMedia([mediaItem])
                }
            })
        }
    }
    
    public func unlikePost(with id: String) {
        
        pendingTasks[id] = false
        
        reliableNetworkTaskManager.performTask { (failure) in
            
            guard self.pendingTasks[id] == false else {
                return
            }
            
            let response = self.communicator.unlikePost(with: id)
            guard response.succeeded else {
                return failure()
            }
            
            self.pendingTasks.removeValue(forKey: id)
            
            self.mediaDataStore.loadMediaItem(with: id, completion: { (mediaItem) in
                if let mediaItem = mediaItem {
                    var mediaItem = mediaItem
                    mediaItem.viewerHasLiked = false
                    self.mediaDataStore.archiveMedia([mediaItem])
                }
            })
        }
    }
    
}
