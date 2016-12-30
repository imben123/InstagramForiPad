//
//  MockURLSession.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
@testable import InstagramData

class MockURLSession: URLSession {
    
    var responseBody: Data?
    var response: URLResponse?
    var error: Error?
    
    var requests: [URLRequest] = []
    
    private var completionHandler: ((Data?, URLResponse?, Error?) -> Void)? = nil
    
    override func dataTask(with request: URLRequest,
                           completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        self.requests.append(request)
        
        return MockURLSessionDataTask(responseBody: responseBody,
                                      response: response,
                                      error: error,
                                      completionHandler: completionHandler)
    }
    
}

fileprivate class MockURLSessionDataTask: URLSessionDataTask {
    
    private let _responseBody: Data?
    private let _response: URLResponse?
    private let _error: Error?
    
    private let completionHandler: (Data?, URLResponse?, Error?) -> Void

    init(responseBody: Data?,
         response: URLResponse?,
         error: Error?,
         completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self._responseBody = responseBody
        self._response = response
        self._error = error
        self.completionHandler = completionHandler
    }
    
    override func resume() {
        self.completionHandler(_responseBody, _response, _error)
    }
    
}
