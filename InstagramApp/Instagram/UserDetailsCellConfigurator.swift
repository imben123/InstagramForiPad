//
//  UserDetailsCellConfigurator.swift
//  Instagram
//
//  Created by Ben Davis on 06/05/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import Foundation
import InstagramData
import SDWebImage

protocol UserDetailsCellContents: class {
    var profilePictureView: UIImageView! { get }
    var usernameLabel: UILabel! { get }
    var followingLabel: UILabel! { get }
    var followersLabel: UILabel! { get }
    var postsLabel: UILabel! { get }
    var bioTextView: UITextView! { get }
    var followButton: UIButton! { get }
    var followButtonSpinner: UIActivityIndicatorView! { get }

    var userId: String! { get set }
    func setUser(_ user: User, followingStateKnown: Bool)
    
}

extension UserDetailsCellContents {
    
    func setUser(_ user: User, followingStateKnown: Bool) {
        self.userId = user.id
        usernameLabel.text = user.fullName
        setupForUser(user, followingStateKnown: followingStateKnown)
    }
    
    private func setupForUser(_ user: User, followingStateKnown: Bool) {
        
        setImage(from: user.profilePictureURL)
        
        usernameLabel.text = user.fullName
        postsLabel.text = "\(user.mediaCount)"
        followersLabel.text = "\(user.followedByCount)"
        followingLabel.text = "\(user.followsCount)"
        bioTextView.text = user.biography
        
        if followingStateKnown {
            configureFollowButton(for: user)
        } else {
            configureFollowButtonForUnknownFollowState()
        }
    }
    
    private func configureFollowButtonForUnknownFollowState() {
        followButton.setTitle("Loading...", for: .normal)
        followButton.setTitleColor(UIColor.black, for: .normal)
        followButton.backgroundColor = .clear
        followButton.isUserInteractionEnabled = false
        followButton.layer.borderColor = UIColor.black.cgColor
    }
    
    private func configureFollowButton(for user: User) {
        if user.followedByViewer {
            followButton.setTitle("Unfollow", for: .normal)
            followButton.setTitleColor(followButton.tintColor, for: .normal)
            followButton.backgroundColor = .clear
        } else {
            followButton.setTitle("Follow", for: .normal)
            followButton.setTitleColor(.white, for: .normal)
            followButton.backgroundColor = followButton.tintColor
        }
        followButton.isUserInteractionEnabled = true
        followButton.layer.borderColor = followButton.tintColor.cgColor
    }
    
    private func followButtonTitle(for user: User) -> String {
        return (user.followedByViewer ? "Unfollow" : "Follow")
    }
    
    private func setImage(from url: URL, highPriority: Bool = false) {

        let image = SDImageCache.shared.imageFromMemoryCache(forKey: url.absoluteString)
        if let image = image {
            profilePictureView.image = image
            return
        }
        
        let options = highPriority ? SDWebImageOptions.highPriority : []
        SDWebImageManager.shared.loadImage(with: url,
                                           options: options,
                                           progress: nil)
        { [weak self] (image, data, error, cacheType, finished, url) in
            if image != nil {
                self?.profilePictureView.image = image
            }
        }
    }
}
