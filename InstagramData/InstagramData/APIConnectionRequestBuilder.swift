//
//  APIConnectionRequestBuilder.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation

class APIConnectionRequestBuilder {
    
    let csrftoken: String?
    let sessionid: String?
    let baseURL: URL
    
    init(baseURL: URL, csrftoken: String?, sessionid: String?) {
        self.baseURL = baseURL
        self.csrftoken = csrftoken
        self.sessionid = sessionid
    }
    
    func makeURLRequest(path: String, payload: [String: String]?) -> URLRequest {
        var result = URLRequest(url: makeURL(from: path))
        addHeaders(to: &result)
        addHTTPMethodAndBody(to: &result, payload:payload)
        return result
    }
    
    private func makeURL(from path: String) -> URL {
        return URL(string: path, relativeTo: baseURL)!
    }
    
    private func addHeaders(to request: inout URLRequest) {
        
        if let csrftoken = csrftoken {
            request.addValue(csrftoken, forHTTPHeaderField: "x-csrftoken")
        }
        
        request.addValue(createCookie(), forHTTPHeaderField: "cookie")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request.addValue("https://www.instagram.com/", forHTTPHeaderField: "referer")
    }
    
    private func createCookie() -> String {
        var result = ""
        
        if let csrftoken = csrftoken {
            result += "csrftoken=\(csrftoken)"
        }
        
        if let sessionid = sessionid {
            result += "; sessionid=\(sessionid)"
        }
        
        return result
    }
    
    func addHTTPMethodAndBody(to request: inout URLRequest, payload: [String: String]?) {
        if let payload = payload {
            request.httpMethod = "POST"
            request.setURLEncodedBody(parameters: payload)
        } else {
            request.httpMethod = "GET"
        }
    }
    
}
