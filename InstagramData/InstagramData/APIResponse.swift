//
//  APIResponse.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
import SwiftToolbox

struct APIResponse: Equatable {
    
    let responseCode: Int
    let responseBody: [String: Any]?
    let urlResponse: URLResponse?
    var succeeded: Bool {
        return responseCode >= 200 && responseCode < 400
    }
    
    static let noInternetResponse = APIResponse(responseCode: 0, responseBody: nil, urlResponse: nil)
    
    public static func ==(lhs: APIResponse, rhs: APIResponse) -> Bool {
        
        let lhsResponseBody = lhs.responseBody as NSDictionary?
        let rhsResponseBody = rhs.responseBody as NSDictionary?
        
        return ( lhs.responseCode == rhs.responseCode &&
            lhsResponseBody == rhsResponseBody &&
            lhs.urlResponse == rhs.urlResponse)
        
    }
    
}

extension APIResponse: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return "APIResponse; code: \(responseCode); body: \(responseBody)"
    }
    
}
