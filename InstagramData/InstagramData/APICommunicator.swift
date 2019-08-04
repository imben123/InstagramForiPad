//
//  APICommunicator.swift
//  InstagramData
//
//  Created by Ben Davis on 29/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation

class APICommunicator {
    
    static let fullUserProperties = "id,profile_pic_url,full_name,username,biography,external_url," +
                                    "followed_by{count},follows{count},followed_by_viewer,follows_viewer,media{count}"
    
    static let fullCommentProperties: String = "id,text,user{\(fullUserProperties)}"

    static let fullMediaProperties = "id,date,dimensions{height,width},owner{\(fullUserProperties)}," +
                                     "code,is_video,caption,display_src,thumbnail_src,comments_disabled," +
                                     "comments.last(4){count,nodes{\(fullCommentProperties)},page_info}," +
                                     "likes{count,viewer_has_liked}"
    
    let fullUserProperties: String = APICommunicator.fullUserProperties
    let fullMediaProperties: String = APICommunicator.fullMediaProperties
    let fullCommentProperties: String = APICommunicator.fullCommentProperties
    
    private var feedQueryHash: String?
    private var commentsQueryHash: String?
    
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
    
    func getUserFeed(userId: String, numberOfPosts: Int, from previousIndex: String? = nil) -> APIResponse {
        
//        let positionIndicator: String
//        if let previousIndex = previousIndex {
//            positionIndicator = "after(\(previousIndex),\(numberOfPosts))"
//        } else {
//            positionIndicator = "first(\(numberOfPosts))"
//        }
//        
//        let payload = [
//            "q": "ig_user(\(userId)){media.\(positionIndicator){count,nodes{\(fullMediaProperties)},page_info}}"
//        ]
//        
//        let response = self.connection.makeRequest(path: "/query/", payload: payload)
//        return response
        return .noInternetResponse
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
    
    func getUser(for id: String) -> APIResponse {
        
//        let payload = [
//            "q": "ig_user(\(id)){\(fullUserProperties)}"
//        ]
//        
//        let response = self.connection.makeRequest(path: "/query/", payload: payload)
//        return response
        return .noInternetResponse
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
}
