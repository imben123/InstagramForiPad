//
//  UsersManager.swift
//  InstagramData
//
//  Created by Ben Davis on 06/05/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import Foundation
import SwiftToolbox
import SwiftyJSON

public class UsersDataStore {

    private static let backgroundQueue = DispatchQueue(label: "uk.co.bendavisapps.UsersDataStore", qos: .background)

    private let communicator: APICommunicator
    
    private var taskDispatcher: TaskDispatcher
    private var users: [String: User] = [:]
    
    convenience init(communicator: APICommunicator) {
        self.init(communicator: communicator, taskDispatcher: TaskDispatcher(queue: UsersDataStore.backgroundQueue))
    }
    
    init(communicator: APICommunicator, taskDispatcher: TaskDispatcher) {
        self.communicator = communicator
        self.taskDispatcher = taskDispatcher
    }
    
    func addUser(_ user: User) {
        users[user.id] = user
    }
    
    public func fetchUser(_ user: User, 
                          completion: @escaping (User?)->Void) {
        taskDispatcher.async {
            let response = self.communicator.getUser(for: user.username)
            
            if response.succeeded {
                let userJSON = JSON(response.responseBody!)["graphql"]["user"]
                let user = User(json: userJSON)
                self.addUser(user)
                self.taskDispatcher.asyncOnMainQueue {
                    completion(user)
                }
            } else {
                self.taskDispatcher.asyncOnMainQueue {
                    completion(nil)
                }
            }
        }
    }
}
