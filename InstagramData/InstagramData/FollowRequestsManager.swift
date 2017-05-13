//
//  FollowRequestsManager.swift
//  InstagramData
//
//  Created by Ben Davis on 08/05/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import SwiftToolbox
import Reachability

public class FollowRequestsManager: ReliableSwitchRequestsManager {
    
    let communicator: APICommunicator
    
    convenience init(communicator: APICommunicator) {
        let queue = DispatchQueue(label: "FollowRequestsManagerQueue")
        let taskDispatcher = TaskDispatcher(queue: queue)
        let reachability = Reachability(hostName: "instagram.com")!
        let reliableNetworkTaskManager = ReliableNetworkTaskManager(reachability: reachability,
                                                                    taskDispatcher: taskDispatcher)
        self.init(communicator: communicator,
                  taskDispatcher: taskDispatcher,
                  reliableNetworkTaskManager: reliableNetworkTaskManager)
    }
    
    init(communicator: APICommunicator,
         taskDispatcher: TaskDispatcher,
         reliableNetworkTaskManager: ReliableNetworkTaskManager) {
        
        self.communicator = communicator
        super.init(taskDispatcher: taskDispatcher,
                   reliableNetworkTaskManager: reliableNetworkTaskManager,
                   switchOnCall: communicator.followUser(withId:),
                   switchOffCall: communicator.unfollowUser(withId:))
    }
    
    public func followUser(with id: String, completion: (()->Void)? = nil) {
        super.switchOn(for: id, completion: completion)
    }
    
    public func unfollowUser(with id: String, completion: (()->Void)? = nil) {
        super.switchOff(for: id, completion: completion)
    }
    
}
