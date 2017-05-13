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

public class LikeReqestsManager: ReliableSwitchRequestsManager {
    
    let communicator: APICommunicator
    let mediaDataStore: MediaDataStore
    
    convenience init(communicator: APICommunicator, mediaDataStore: MediaDataStore) {
        let queue = DispatchQueue(label: "LikeReqestsManagerQueue")
        let taskDispatcher = TaskDispatcher(queue: queue)
        let reachability = Reachability(hostName: "instagram.com")!
        let reliableNetworkTaskManager = ReliableNetworkTaskManager(reachability: reachability,
                                                                    taskDispatcher: taskDispatcher)
        self.init(communicator: communicator,
                  mediaDataStore: mediaDataStore,
                  taskDispatcher: taskDispatcher,
                  reliableNetworkTaskManager: reliableNetworkTaskManager)
    }
    
    init(communicator: APICommunicator,
         mediaDataStore: MediaDataStore,
         taskDispatcher: TaskDispatcher,
         reliableNetworkTaskManager: ReliableNetworkTaskManager) {
        
        self.communicator = communicator
        self.mediaDataStore = mediaDataStore
        super.init(taskDispatcher: taskDispatcher,
                   reliableNetworkTaskManager: reliableNetworkTaskManager,
                   switchOnCall: communicator.likePost(with:),
                   switchOffCall: communicator.unlikePost(with:))
    }
    
    public func likePost(with id: String, completion: (()->())? = nil) {
        
        super.switchOn(for: id) { 
            self.mediaDataStore.loadMediaItem(with: id, completion: { (mediaItem) in
                if let mediaItem = mediaItem {
                    var mediaItem = mediaItem
                    mediaItem.viewerHasLiked = true
                    self.mediaDataStore.archiveMedia([mediaItem], completion: completion)
                }
            })
        }
    }
    
    public func unlikePost(with id: String, completion: (()->())? = nil) {
        
        super.switchOff(for: id) { 
            self.mediaDataStore.loadMediaItem(with: id, completion: { (mediaItem) in
                if let mediaItem = mediaItem {
                    var mediaItem = mediaItem
                    mediaItem.viewerHasLiked = false
                    self.mediaDataStore.archiveMedia([mediaItem], completion: completion)
                }
            })
        }
    }
    
}
