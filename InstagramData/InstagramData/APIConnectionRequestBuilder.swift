//
//  APIConnectionRequestBuilder.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation

class APIConnectionRequestBuilder {
    
    let baseURL: URL

    private var cookies: [HTTPCookie] = []
    
    private var csrftoken: String? {
        for cookie in cookies {
            if cookie.name == "csrftoken" {
                return cookie.value
            }
        }
        return nil
    }
    
    init(baseURL: URL, cookies: [HTTPCookie]) {
        self.baseURL = baseURL
        self.cookies = cookies
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

        request.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request.addValue("https://www.instagram.com/", forHTTPHeaderField: "referer")
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
