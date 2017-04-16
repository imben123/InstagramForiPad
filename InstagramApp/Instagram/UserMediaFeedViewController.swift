//
//  UserMediaFeedViewController.swift
//  Instagram
//
//  Created by Ben Davis on 02/03/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import Foundation
import InstagramData

class UserMediaFeedViewController: MediaFeedViewController {
    
    let username: String
    let userId: String
    
    init(userId: String, username: String) {
        self.userId = userId
        self.username = username
        super.init(mediaFeed: InstagramData.shared.createUserProfileMediaFeed(for: userId))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = username
    }
    
    override func profilePictureTapped(forUserWithId userId: String, username: String) {
        if userId != self.userId {
            super.profilePictureTapped(forUserWithId: userId, username: username)
        } else {
            dismiss(animated: true)
        }
    }
    
}
