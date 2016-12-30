//
//  MockAPICommunicator.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
@testable import InstagramData

class MockAPICommunicator: APICommunicator {
    
    var testAuthenticated: Bool = false
    var testResonse: APIResponse = .noInternetResponse
    
    override var authenticated: Bool {
        return testAuthenticated
    }

    override func login(username: String, password: String) -> APIResponse {
        return testResonse
    }
    
    override func getFeed(numberOfPosts: Int, from previousIndex: String?) -> APIResponse {
        return testResonse
    }

}
