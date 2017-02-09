//
//  MediaManager.swift
//  InstagramData
//
//  Created by Ben Davis on 07/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import Foundation
import SwiftToolbox

public class MediaManager {
    
    let communicator: APICommunicator
    let taskDispatcher: TaskDispatcher
    let mediaDataStore: MediaDataStore
    
    init(communicator: APICommunicator, mediaDataStore: MediaDataStore, taskDispatcher: TaskDispatcher) {
        self.communicator = communicator
        self.mediaDataStore = mediaDataStore
        self.taskDispatcher = taskDispatcher
    }
    
    convenience init(communicator: APICommunicator, mediaDataStore: MediaDataStore) {
        let queue = DispatchQueue(label: "MediaManager.queue")
        self.init(communicator: communicator,
                  mediaDataStore: mediaDataStore,
                  taskDispatcher: TaskDispatcher(queue: queue))
    }
    
    public func updateMediaItem(_ originalMediaItem: MediaItem, completion: ((_ mediaItem: MediaItem)->Void)? = nil) {
        taskDispatcher.async {
            let response = self.communicator.getPost(with: originalMediaItem.code)
            if response.succeeded {
                let mediaDictionary = response.responseBody?["media"] as! [String: Any]
                let mediaItem = MediaItem(jsonDictionary: mediaDictionary, original: originalMediaItem)
                self.mediaDataStore.archiveMedia([mediaItem])
                DispatchQueue.main.async {
                    completion?(mediaItem)
                }
            }
        }
    }
    
}
