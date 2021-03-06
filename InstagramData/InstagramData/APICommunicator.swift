//
//  APICommunicator.swift
//  InstagramData
//
//  Created by Ben Davis on 29/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation

class APICommunicator {
        
    private var feedQueryHash: String?
    private var commentsQueryHash: String?
    private var userQueryHashes: [String: String] = [:]
    
    private let connection: APIConnection

    convenience init() {
        self.init(APIConnection())
    }
    
    init(_ connection: APIConnection) {
        self.connection = connection
    }
    
    var authenticated: Bool {
        return connection.authenticated
    }
    
    func login(username: String, password: String) -> APIResponse {

        connection.resetCookies()
        
        let payload = [
            "username": username,
            "password": password
        ]
        
        let response = connection.makeRequest(path: "/accounts/login/ajax/",
                                              payload: payload,
                                              requiresAuthentication: false)
        return response
    }
    
    func getFeed(numberOfPosts: Int, from previousIndex: String? = nil) -> APIResponse {

        if let queryHashesFailureResponse = fetchQueryHashesIfNeeded() {
            return queryHashesFailureResponse
        }

        var variables: [String: Any] = [
          "cached_feed_item_ids": [],
          "fetch_media_item_count": numberOfPosts,
          "fetch_comment_count": 4,
          "fetch_like": 3,
          "has_stories": false,
          "has_threaded_comments": false
        ]

        if let previousIndex = previousIndex {
            variables["fetch_media_item_cursor"] = previousIndex
        }

        let variablesJSON = try! JSONSerialization.data(withJSONObject: variables, options: [])
        let variablesString = String(data: variablesJSON, encoding: .utf8)!
        let urlParameters = ["variables": variablesString, "query_hash": feedQueryHash]

        let response = self.connection.makeRequest(path: "/graphql/query", urlParameters: urlParameters)
        return response
    }
    
    func getUserFeed(username: String, 
                     userId: String, 
                     numberOfPosts: Int,
                     from endCursor: String? = nil) -> APIResponse {
        
        let fetchQueryHashResult = getUserQueryHash(for: username)
        let queryHash: String
        switch fetchQueryHashResult {
        case .failure(.parseFailure(let errorMessage)):
            print(errorMessage)
            return .noInternetResponse
        case .failure(.requestFailed(let failureResponse)):
            return failureResponse
        case .success(let queryHashResult):
            queryHash = queryHashResult
        }
        
        var variables: [String: Any] = [
            "id": userId,
            "first": numberOfPosts
        ]
        
        if let endCursor = endCursor {
            variables["after"] = endCursor
        }
        
        let variablesJSON = try! JSONSerialization.data(withJSONObject: variables, options: [])
        let variablesString = String(data: variablesJSON, encoding: .utf8)!
        let urlParameters = ["variables": variablesString, "query_hash": queryHash]
        
        let response = self.connection.makeRequest(path: "/graphql/query", urlParameters: urlParameters)
        return response
    }
    
    func getPost(with code: String) -> APIResponse {
        
//        let payload = [
//            "q": "ig_shortcode(\(code)){\(fullMediaProperties)}"
//        ]
//        
//        let response = self.connection.makeRequest(path: "/query/", payload: payload)
//        return response
        return .noInternetResponse
    }
    
    func likePost(with id: String) -> APIResponse {
//        let path = "/web/likes/\(id)/like/"
//        let response = self.connection.makeRequest(path: path, payload: [:])
//        return response
        return .noInternetResponse
    }
    
    func unlikePost(with id: String) -> APIResponse {
//        let path = "/web/likes/\(id)/unlike/"
//        let response = self.connection.makeRequest(path: path, payload: [:])
//        return response
        return .noInternetResponse
    }
    
    func getComments(for mediaCode: String, numberOfComments: Int, from previousIndex: String?) -> APIResponse {

        if let queryHashesFailureResponse = fetchQueryHashesIfNeeded() {
            return queryHashesFailureResponse
        }

        var variables: [String: Any] = [
          "first": numberOfComments,
          "shortcode": mediaCode
        ]

        if let previousIndex = previousIndex {
            variables["after"] = previousIndex
        }

        let variablesJSON = try! JSONSerialization.data(withJSONObject: variables, options: [])
        let variablesString = String(data: variablesJSON, encoding: .utf8)!
        let urlParameters = ["variables": variablesString, "query_hash": commentsQueryHash]
        
        let response = self.connection.makeRequest(path: "/graphql/query/", urlParameters: urlParameters)
        return response
    }
    
    func getUser(for username: String) -> APIResponse {
        let urlParameters = ["__a": "1"]
        let response = self.connection.makeRequest(path: "/\(username)", urlParameters: urlParameters)
        return response
    }
    
    func followUser(withId userId: String) -> APIResponse {
//        let path = "/web/friendships/\(userId)/follow/"
//        let response = self.connection.makeRequest(path: path, payload: [:])
//        return response
        return .noInternetResponse
    }
    
    func unfollowUser(withId userId: String) -> APIResponse {
//        let path = "/web/friendships/\(userId)/unfollow/"
//        let response = self.connection.makeRequest(path: path, payload: [:])
//        return response
        return .noInternetResponse
    }

    private func fetchQueryHashesIfNeeded() -> APIResponse? {
        guard feedQueryHash == nil else { return nil }
        let queryHashFinder = QueryHashFinder(connection: connection)
        let result = queryHashFinder.fetchQueryHash()
        switch result {
        case .success(let queryHashResult):
            feedQueryHash = queryHashResult.feedQueryHash
            commentsQueryHash = queryHashResult.commentsQueryHash
            return nil

        case .failure(.parseFailure(let errorMessage)):
            print(errorMessage)
            return .noInternetResponse

        case .failure(.requestFailed(let failureResponse)):
            return failureResponse
        }
    }
    
    private func getUserQueryHash(for username: String) -> Result<String, UserQueryHashFinder.Failure> {
        if let queryHash = userQueryHashes[username] { return .success(queryHash) }
        let queryHashFinder = UserQueryHashFinder(connection: connection)
        let result = queryHashFinder.fetchUserQueryHash(for: username)
        if case .success(let queryHash) = result {
            userQueryHashes[username] = queryHash
        }
        return result
    }
}
