//
//  MockAPIConnection.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
@testable import InstagramData

struct MockAPIConnectionMakeParameters {
    let path: String
    let payload: [String : String]?
    let urlParameters: [String: String?]
}

class MockAPIConnection: APIConnection {
    
    var testAuthenticated: Bool = false
    var testResponse: APIResponse = .noInternetResponse
    
    var makeRequestCalls: [MockAPIConnectionMakeParameters] = []

    override var authenticated: Bool {
        return testAuthenticated
    }
    
    override func makeRequest(path: String,
                              payload: [String : String]? = nil, 
                              urlParameters: [String : String?] = [:],
                              requiresAuthentication: Bool = true) -> APIResponse {
        makeRequestCalls.append(MockAPIConnectionMakeParameters(path: path,
                                                                payload: payload,
                                                                urlParameters: urlParameters))
        return testResponse
    }
    
}
