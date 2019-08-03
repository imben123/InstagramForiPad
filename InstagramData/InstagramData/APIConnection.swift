//
//  APIConnection.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation

class APIConnection {
    
    private let cookieStore = HTTPCookieStorage.shared
    private var cookies: [HTTPCookie] {
        return cookieStore.cookies ?? []
    }
    private let baseURL: URL = URL(string:"https://www.instagram.com")!
    
    private var queryHash: String?

    private let connection: HTTPConnection
    
    var authenticated: Bool {
        for cookie in cookies {
            if cookie.name == "sessionid" && cookie.value != "" {
                return true
            }
        }
        return false
    }

    private var defaultURLParameters: [String: String?] {
        if let queryHash = queryHash {
            return ["query_hash": queryHash]
        } else {
            return [:]
        }
    }
    
    convenience init() {
        self.init(connection: HTTPConnection(session: URLSession.shared))
    }
    
    init(connection: HTTPConnection) {
        self.connection = connection
        connection.delegate = self
    }

    func resetCookies() {
        cookieStore.removeCookies(since: Date(timeIntervalSince1970: 0))

        let cookie = HTTPCookie(properties: [
            HTTPCookiePropertyKey.name: "ig_cb",
            HTTPCookiePropertyKey.domain: "www.instagram.com",
            HTTPCookiePropertyKey.path: "/",
            HTTPCookiePropertyKey.value: "1"
        ])!
        cookieStore.setCookie(cookie)
    }
    
    func makeRequest(path: String,
                     payload: [String: String]? = nil,
                     urlParameters: [String: String?] = [:],
                     requiresAuthentication: Bool = true) -> APIResponse {

        let bootstrapResponse = bootstrapIfNeeded()
        if let bootstrapResponse = bootstrapResponse, bootstrapResponse.responseCode != 200 {
            return bootstrapResponse
        }

        if requiresAuthentication, let authFailureResponse = authenticateAPIQueriesIfNeeded() {
            return authFailureResponse
        }

        let requestBuilder = APIConnectionRequestBuilder(baseURL: baseURL, cookies: cookies)
        let urlParameters = defaultURLParameters.merging(urlParameters, uniquingKeysWith: { $1 })
        let request = requestBuilder.makeURLRequest(path: path,
                                                    payload: payload,
                                                    urlParameters: urlParameters)
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

    private func authenticateAPIQueriesIfNeeded() -> APIResponse? {
        guard queryHash == nil else { return nil }
        let queryHashFinder = QueryHashFinder(connection: self)
        let result = queryHashFinder.fetchQueryHash()
        switch result {
        case .success(let queryHashResult):
            queryHash = queryHashResult.queryHash
            return nil

        case .failure(.parseFailure(let errorMessage)):
            print(errorMessage)
            return .noInternetResponse

        case .failure(.requestFailed(let failureResponse)):
            return failureResponse
        }
    }
}

extension APIConnection: HTTPConnectionDelegate {
    func httpConnection(_ sender: HTTPConnection, receivedCookie cookie: HTTPCookie) {
        cookieStore.setCookie(cookie)
    }
}
