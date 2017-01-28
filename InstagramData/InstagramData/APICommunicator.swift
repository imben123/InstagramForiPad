//
//  APICommunicator.swift
//  InstagramData
//
//  Created by Ben Davis on 29/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation

class APICommunicator {
    
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
        
        let payload = [
            "username": username,
            "password": password
        ]
        
        let response = self.connection.makeRequest(path: "/accounts/login/ajax/", payload: payload)
        return response
    }
    
    func getFeed(numberOfPosts: Int, from previousIndex: String? = nil) -> APIResponse {
        
        let positionIndicator: String
        if let previousIndex = previousIndex {
            positionIndicator = "after(\(previousIndex),\(numberOfPosts))"
        } else {
            positionIndicator = "first(\(numberOfPosts))"
        }
        
        let payload = [
            "q": "ig_me(){feed{media.\(positionIndicator){nodes{id,attribution,caption,code,comments.last(4){count,nodes{id,created_at,text,user{id,profile_pic_url,username}},page_info},comments_disabled,date,dimensions{height,width},display_src,thumbnail_src,is_video,likes{count,nodes{user{id,profile_pic_url,username}},viewer_has_liked},location{id,has_public_page,name,slug},owner{id,blocked_by_viewer,followed_by_viewer,full_name,has_blocked_viewer,is_private,profile_pic_url,requested_by_viewer,username},usertags{nodes{user{username},x,y}},video_url,video_views},page_info}},id,profile_pic_url,username}"
        ]
        
        let response = self.connection.makeRequest(path: "/query/", payload: payload)
        return response
    }
    
    func likePost(with id: String) -> APIResponse {
        let path = "/web/likes/\(id)/like/"
        let response = self.connection.makeRequest(path: path, payload: [:])
        return response
    }
    
    func unlikePost(with id: String) -> APIResponse {
        let path = "/web/likes/\(id)/unlike/"
        let response = self.connection.makeRequest(path: path, payload: [:])
        return response
    }
}
