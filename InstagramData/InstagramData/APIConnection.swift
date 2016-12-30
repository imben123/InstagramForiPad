//
//  APIConnection.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation

class APIConnection {
    
    fileprivate var csrftoken: String? = nil
    fileprivate var sessionid: String? = nil
    private let baseURL: URL = URL(string:"https://www.instagram.com")!
    
    private let connection = HTTPConnection()
    
    init() {
        connection.delegate = self
    }
    
    func makeRequest(path: String, payload: [String: String]?) -> APIResponse {
        
        let bootstrapResponse = bootstrapIfNeeded()
        if let bootstrapResponse = bootstrapResponse, bootstrapResponse.responseCode != 200 {
            return bootstrapResponse
        }
        
        let requestBuilder = APIConnectionRequestBuilder(baseURL: baseURL, csrftoken: csrftoken, sessionid: sessionid)
        let request = requestBuilder.makeURLRequest(path: path, payload: payload)
        guard let result = connection.makeSynchronousRequest(request) else {
            return .noInternetResponse
        }
        return result
    }
    
    private func bootstrapIfNeeded() -> APIResponse? {
        guard csrftoken == nil else {
            return nil
        }

        let requestBuilder = APIConnectionRequestBuilder(baseURL: baseURL, csrftoken: csrftoken, sessionid: sessionid)
        let request = requestBuilder.makeURLRequest(path: "/", payload: nil)
        guard let result = connection.makeSynchronousRequest(request) else {
            return .noInternetResponse
        }
        return result
    }
    
}

extension APIConnection: HTTPConnectionDelegate {
    func httpConnection(_ sender: HTTPConnection, receivedCookie cookie: HTTPCookie) {
        if cookie.name == "csrftoken" {
            csrftoken = cookie.value
        } else if cookie.name == "sessionid" {
            sessionid = cookie.value
        }
    }
}
