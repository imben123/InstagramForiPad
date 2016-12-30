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
    
    public var authenticated: Bool {
        return communicator.authenticated
    }
    
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
        guard let responseBody = response?.responseBody else {
            return false
        }
        
        let json = JSON(responseBody)
        let result = json["authenticated"].bool
        
        return result ?? false
    }
    
    public func logout() {
        let cookieStore = HTTPCookieStorage.shared
        if let cookies = cookieStore.cookies {
            for cookie in cookies {
                cookieStore.deleteCookie(cookie)
            }
        }
    }
}
