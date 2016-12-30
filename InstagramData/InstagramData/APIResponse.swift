//
//  APIResponse.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation

struct APIResponse {
    
    let responseCode: Int
    let responseBody: [String: Any]?
    let urlResponse: URLResponse?
    var succeeded: Bool {
        return responseCode == 200
    }
    
    static let noInternetResponse = APIResponse(responseCode: 0, responseBody: nil, urlResponse: nil)
    
}

extension APIResponse: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return "APIResponse; code: \(responseCode); body: \(responseBody)"
    }
    
}
