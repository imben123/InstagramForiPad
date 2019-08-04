//
//  MockAPICommunicator.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation
@testable import InstagramData

class MockAPICommunicator: APICommunicator {
    
    var testAuthenticated: Bool = false
    var testResponse: APIResponse = .noInternetResponse
    
    var getPostCallCount: Int = 0
    var getPostParameter: String? = nil
    
    var likePostCallCount: Int = 0
    var likePostParameter: String? = nil
    
    var unlikePostCallCount: Int = 0
    var unlikePostParameter: String? = nil
    
    var followUserCallCount: Int = 0
    var followUserParameter: String? = nil
    
    var unfollowUserCallCount: Int = 0
    var unfollowUserParameter: String? = nil
    
    var getUserCallCount: Int = 0
    
    override var authenticated: Bool {
        return testAuthenticated
    }

    override func login(username: String, password: String) -> APIResponse {
        return testResponse
    }
    
    override func getFeed(numberOfPosts: Int, from previousIndex: String?) -> APIResponse {
        return testResponse
    }
    
    override func getPost(with code: String) -> APIResponse {
        getPostCallCount += 1
        getPostParameter = code
        return testResponse
    }

    override func likePost(with id: String) -> APIResponse {
        likePostCallCount += 1
        likePostParameter = id
        return testResponse
    }
    
    override func unlikePost(with id: String) -> APIResponse {
        unlikePostCallCount += 1
        unlikePostParameter = id
        return testResponse
    }
    
    override func getComments(for mediaCode: String, numberOfComments: Int, from previousIndex: String?) -> APIResponse {
        return testResponse
    }
    
    override func getUser(for id: String) -> APIResponse {
        getUserCallCount += 1
        return testResponse
    }
    
    override func followUser(withId userId: String) -> APIResponse {
        followUserCallCount += 1
        followUserParameter = userId
        return testResponse
    }
    
    override func unfollowUser(withId userId: String) -> APIResponse {
        unfollowUserCallCount += 1
        unfollowUserParameter = userId
        return testResponse
    }
}
