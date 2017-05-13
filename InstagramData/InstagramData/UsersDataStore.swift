//
//  UsersManager.swift
//  InstagramData
//
//  Created by Ben Davis on 06/05/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import Foundation
import SwiftToolbox

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
    
    public func fetchUser(for id: String, forceUpdate: Bool = false, completion: @escaping (User?)->Void) {
        if let user = users[id], !forceUpdate {
            completion(user)
        } else {
            downloadUser(with: id, completion: completion)
        }
    }
    
    private func downloadUser(with id: String, completion: @escaping (User?)->Void) {
        taskDispatcher.async {
            let response = self.communicator.getUser(for: id)
            
            if response.succeeded {
                let user = User(jsonDictionary: response.responseBody!)
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
