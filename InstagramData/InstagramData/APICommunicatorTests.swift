//
//  APICommunicatorTests.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import XCTest
@testable import InstagramData

class APICommunicatorTests: XCTestCase {
    
    var sut: APICommunicator!
    var mockConnection: MockAPIConnection!
    
    let expectedResponse = APIResponse(responseCode: 123, responseBody: ["foo": "bar"], urlResponse: nil)
    
    override func setUp() {
        super.setUp()
        mockConnection = MockAPIConnection()
        mockConnection.testResponse = expectedResponse
        sut = APICommunicator(mockConnection)
    }
    
    func testAuthenticated() {
        mockConnection.testAuthenticated = false
        XCTAssertFalse(sut.authenticated)
        
        mockConnection.testAuthenticated = true
        XCTAssertTrue(sut.authenticated)
    }
    
    func testLogin() {
        let response = sut.login(username: "username", password: "password")
        XCTAssertEqual(mockConnection.makeRequestCalls.count, 1)
        XCTAssertEqual(mockConnection.makeRequestCalls.first!.path, "/accounts/login/ajax/")
        XCTAssertEqual(mockConnection.makeRequestCalls.first!.payload!, [
            "username": "username",
            "password": "password"
            ])
        XCTAssertEqual(response, expectedResponse)
    }
    
    func testGetFeed() {
        let response = sut.getFeed(numberOfPosts: 1)
        XCTAssertEqual(mockConnection.makeRequestCalls.count, 1)
        XCTAssertEqual(mockConnection.makeRequestCalls.first!.path, "/query/")
        XCTAssertNotNil(mockConnection.makeRequestCalls.first!.payload?["q"])
        XCTAssert(mockConnection.makeRequestCalls.first!.payload!["q"]!.contains(".first(1)"))
        XCTAssertEqual(response, expectedResponse)
    }
    
    func testGetMoreFeed() {
        let response = sut.getFeed(numberOfPosts: 1, from: "foobar")
        XCTAssertEqual(mockConnection.makeRequestCalls.count, 1)
        XCTAssertEqual(mockConnection.makeRequestCalls.first!.path, "/query/")
        XCTAssertNotNil(mockConnection.makeRequestCalls.first!.payload?["q"])
        XCTAssert(mockConnection.makeRequestCalls.first!.payload!["q"]!.contains(".after(foobar,1)"))
        XCTAssertEqual(response, expectedResponse)
    }
    
    func testGetUserFeed() {
        let response = sut.getUserFeed(userId: "48567354", numberOfPosts: 1, from: nil)
        XCTAssertEqual(mockConnection.makeRequestCalls.count, 1)
        XCTAssertEqual(mockConnection.makeRequestCalls.first!.path, "/query/")
        XCTAssertNotNil(mockConnection.makeRequestCalls.first!.payload?["q"])
        XCTAssert(mockConnection.makeRequestCalls.first!.payload!["q"]!.contains(".first(1)"))
        XCTAssert(mockConnection.makeRequestCalls.first!.payload!["q"]!.contains("48567354"))
        XCTAssertEqual(response, expectedResponse)
    }
    
    func testGetMoreUserFeed() {
        let response = sut.getUserFeed(userId: "48567354", numberOfPosts: 1, from: "foobar")
        XCTAssertEqual(mockConnection.makeRequestCalls.count, 1)
        XCTAssertEqual(mockConnection.makeRequestCalls.first!.path, "/query/")
        XCTAssertNotNil(mockConnection.makeRequestCalls.first!.payload?["q"])
        XCTAssert(mockConnection.makeRequestCalls.first!.payload!["q"]!.contains(".after(foobar,1)"))
        XCTAssert(mockConnection.makeRequestCalls.first!.payload!["q"]!.contains("48567354"))
        XCTAssertEqual(response, expectedResponse)
    }
    
    func testGetPost() {
        let response = sut.getPost(with: "post-id")
        XCTAssertEqual(mockConnection.makeRequestCalls.count, 1)
        XCTAssertEqual(mockConnection.makeRequestCalls.first!.path, "/query/")
        XCTAssertNotNil(mockConnection.makeRequestCalls.first!.payload?["q"])
        XCTAssert(mockConnection.makeRequestCalls.first!.payload!["q"]!.contains("ig_shortcode(post-id)"))
        XCTAssertEqual(response, expectedResponse)
    }
    
    func testLikePost() {
        let response = sut.likePost(with: "12345")
        XCTAssertEqual(mockConnection.makeRequestCalls.count, 1)
        XCTAssertEqual(mockConnection.makeRequestCalls.first!.path, "/web/likes/12345/like/")
        XCTAssertNotNil(mockConnection.makeRequestCalls.first!.payload)
        XCTAssertEqual(mockConnection.makeRequestCalls.first!.payload?.count, 0)
        XCTAssertEqual(response, expectedResponse)
    }
    
    func testUnlikePost() {
        let response = sut.unlikePost(with: "12345")
        XCTAssertEqual(mockConnection.makeRequestCalls.count, 1)
        XCTAssertEqual(mockConnection.makeRequestCalls.first!.path, "/web/likes/12345/unlike/")
        XCTAssertNotNil(mockConnection.makeRequestCalls.first!.payload)
        XCTAssertEqual(mockConnection.makeRequestCalls.first!.payload?.count, 0)
        XCTAssertEqual(response, expectedResponse)
    }
    
    func testGetCommentsForPost() {
        let response = sut.getComments(for: "mediaCode", numberOfComments: 123, from: "foobar")
        XCTAssertEqual(mockConnection.makeRequestCalls.count, 1)
        XCTAssertEqual(mockConnection.makeRequestCalls.first!.path, "/query/")
        XCTAssertNotNil(mockConnection.makeRequestCalls.first!.payload?["q"])
        XCTAssert(mockConnection.makeRequestCalls.first!.payload!["q"]!.contains("ig_shortcode(mediaCode){comments.before(foobar,123)"))
        XCTAssertEqual(response, expectedResponse)
    }
    
    func testGetUser() {
        let response = sut.getUser(for: "user-id")
        XCTAssertEqual(mockConnection.makeRequestCalls.count, 1)
        XCTAssertEqual(mockConnection.makeRequestCalls.first!.path, "/query/")
        XCTAssertNotNil(mockConnection.makeRequestCalls.first!.payload?["q"])
        XCTAssert(mockConnection.makeRequestCalls.first!.payload!["q"]!.contains("ig_user(user-id)"))
        XCTAssertEqual(response, expectedResponse)
    }
    
    func testFollorUser() {
        let response = sut.followUser(withId: "12345")
        XCTAssertEqual(mockConnection.makeRequestCalls.count, 1)
        XCTAssertEqual(mockConnection.makeRequestCalls.first!.path, "/web/friendships/12345/follow/")
        XCTAssertNotNil(mockConnection.makeRequestCalls.first!.payload)
        XCTAssertEqual(mockConnection.makeRequestCalls.first!.payload?.count, 0)
        XCTAssertEqual(response, expectedResponse)
    }
    
    func testUnfollorUser() {
        let response = sut.unfollowUser(withId: "12345")
        XCTAssertEqual(mockConnection.makeRequestCalls.count, 1)
        XCTAssertEqual(mockConnection.makeRequestCalls.first!.path, "/web/friendships/12345/unfollow/")
        XCTAssertNotNil(mockConnection.makeRequestCalls.first!.payload)
        XCTAssertEqual(mockConnection.makeRequestCalls.first!.payload?.count, 0)
        XCTAssertEqual(response, expectedResponse)
    }
}
