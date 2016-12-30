//
//  AuthManager.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
import SwiftyJSON

public class AuthManager {
    
    let communicator: APICommunicator
    
    init(communicator: APICommunicator) {
        self.communicator = communicator
    }
    
    public func login(username: String, password: String, completion: (()->())?, failure: (()->())?) {
        DispatchQueue.global().async {
            let response = self.communicator.login(username: username, password: password)
            if self.responseMeansLoginSucceeded(response) {
                DispatchQueue.main.async {
                    completion?()
                }
            } else {
                DispatchQueue.main.async {
                    failure?()
                }
            }
        }
    }
    
    private func responseMeansLoginSucceeded(_ response: APIResponse?) -> Bool {
        guard let response = response else {
            return false
        }
        
        let json = JSON(response.responseBody!)
        guard let result = json["authenticated"].bool else {
            return false
        }
        
        return result
    }
}
