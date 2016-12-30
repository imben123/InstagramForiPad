//
//  InstagramData.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation

public class InstagramData {
    
    public static let shared: InstagramData = InstagramData()
    
    let communicator: APICommunicator
    public let authManager: AuthManager
    public let feedManager: FeedManager
    
    init() {
        communicator = APICommunicator()
        authManager = AuthManager(communicator: communicator)
        feedManager = FeedManager(communicator: communicator)
    }
    
}