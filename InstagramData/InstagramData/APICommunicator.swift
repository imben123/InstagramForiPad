//
//  APICommunicator.swift
//  InstagramData
//
//  Created by Ben Davis on 29/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation

class APICommunicator {
    
    private let connection = APIConnection()
    
    func login(username: String, password: String) -> APIResponse {
        
        let payload = [
            "username": username,
            "password": password
        ]
        
        let response = self.connection.makeRequest(path: "/accounts/login/ajax/", payload: payload)
        return response
    }
    
    func getFeed() -> APIResponse {
        let response = self.connection.makeRequest(path: "/?__a=1", payload: nil)
        return response
    }
}
