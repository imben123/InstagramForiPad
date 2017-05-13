//
//  ReliableRequestManager.swift
//  InstagramData
//
//  Created by Ben Davis on 07/05/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import SwiftToolbox
import Reachability

public class ReliableSwitchRequestsManager {
    
    private let switchOnCall: (String)->APIResponse
    private let switchOffCall: (String)->APIResponse
    private let taskDispatcher: TaskDispatcher
    private let reliableNetworkTaskManager: ReliableNetworkTaskManager
    private var pendingTasks: [String:Bool] = [:] // Map of id's to like/unlike request
    
    init(switchOnCall: @escaping (String)->APIResponse,
         switchOffCall: @escaping (String)->APIResponse) {
        
        let queue = DispatchQueue(label: "LikeReqestsManagerQueue")
        let taskDispatcher = TaskDispatcher(queue: queue)
        let reachability = Reachability(hostName: "instagram.com")!
        let reliableNetworkTaskManager = ReliableNetworkTaskManager(reachability: reachability,
                                                                    taskDispatcher: taskDispatcher)

        self.switchOnCall = switchOnCall
        self.switchOffCall = switchOffCall
        self.taskDispatcher = taskDispatcher
        self.reliableNetworkTaskManager = reliableNetworkTaskManager
    }
    
    init(taskDispatcher: TaskDispatcher,
         reliableNetworkTaskManager: ReliableNetworkTaskManager,
         switchOnCall: @escaping (String)->APIResponse,
         switchOffCall: @escaping (String)->APIResponse) {
        
        self.switchOnCall = switchOnCall
        self.switchOffCall = switchOffCall
        self.taskDispatcher = taskDispatcher
        self.reliableNetworkTaskManager = reliableNetworkTaskManager
    }
    
    func switchOn(for id: String, completion: (()->Void)? = nil) {
        
        pendingTasks[id] = true
        
        reliableNetworkTaskManager.performTask { (failure) in
        
            guard self.pendingTasks[id] == true else {
                return
            }
            
            let response = self.switchOnCall(id)
            guard response.succeeded else {
                return failure()
            }
        
            self.taskDispatcher.asyncOnMainQueue {
                completion?()
            }
            self.pendingTasks.removeValue(forKey: id)
        }
    }
    
    
    func switchOff(for id: String, completion: (()->())? = nil) {
        
        pendingTasks[id] = false
        
        reliableNetworkTaskManager.performTask { (failure) in
        
            guard self.pendingTasks[id] == false else {
                return
            }
        
            let response = self.switchOffCall(id)
            guard response.succeeded else {
                return failure()
            }
            
            self.taskDispatcher.asyncOnMainQueue {
                completion?()
            }
            self.pendingTasks.removeValue(forKey: id)
        }
    }
    
}
