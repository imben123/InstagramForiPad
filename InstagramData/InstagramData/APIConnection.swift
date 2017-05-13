//
//  APIConnection.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation

class APIConnection {
    
    fileprivate var cookieStore = HTTPCookieStorage.shared
    private var cookies: [HTTPCookie] {
        return cookieStore.cookies ?? []
    }
    private let baseURL: URL = URL(string:"https://www.instagram.com")!
    
    private let connection: HTTPConnection
    
    var authenticated: Bool {
        for cookie in cookies {
            if cookie.name == "sessionid" && cookie.value != "" {
                return true
            }
        }
        return false
    }
    
    convenience init() {
        self.init(connection: HTTPConnection(session: URLSession.shared))
    }
    
    init(connection: HTTPConnection) {
        self.connection = connection
        connection.delegate = self
    }
    
    func makeRequest(path: String, payload: [String: String]?) -> APIResponse {
        
        cookieStore.removeCookies(since: Date())

        let bootstrapResponse = bootstrapIfNeeded()
        if let bootstrapResponse = bootstrapResponse, bootstrapResponse.responseCode != 200 {
            return bootstrapResponse
        }
        
        let requestBuilder = APIConnectionRequestBuilder(baseURL: baseURL, cookies: cookies)
        let request = requestBuilder.makeURLRequest(path: path, payload: payload)
        guard let result = connection.makeSynchronousRequest(request) else {
            return .noInternetResponse
        }
        
        if result.responseCode != 200 {
            logError(forRequestTo: path, response: result)
        }
        
        return result
    }
    
    private func logError(forRequestTo path: String, response: APIResponse) {
        print()
        print("Failed web request to path: \(path)")
        print("Response: \(response)")
        print()
    }
    
    private func bootstrapIfNeeded() -> APIResponse? {
        guard bootstrapRequired() else {
            return nil
        }

        let requestBuilder = APIConnectionRequestBuilder(baseURL: baseURL, cookies: cookies)
        let request = requestBuilder.makeURLRequest(path: "/", payload: nil)
        guard let result = connection.makeSynchronousRequest(request) else {
            return .noInternetResponse
        }
        return result
    }
    
    private func bootstrapRequired() -> Bool {
        for cookie in cookies {
            if cookie.name == "csrftoken" {
                return false
            }
        }
        return true
    }
    
}

extension APIConnection: HTTPConnectionDelegate {
    func httpConnection(_ sender: HTTPConnection, receivedCookie cookie: HTTPCookie) {
        cookieStore.setCookie(cookie)
    }
}
