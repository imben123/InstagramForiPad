//
//  UserDetailsCell.swift
//  Instagram
//
//  Created by Ben Davis on 07/05/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import UIKit

class UserDetailsCell: UICollectionViewCell, UserDetailsCellContents {

    @IBOutlet var profilePictureView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var followingLabel: UILabel!
    @IBOutlet var followersLabel: UILabel!
    @IBOutlet var postsLabel: UILabel!
    @IBOutlet var bioTextView: UITextView!
    @IBOutlet var followButton: UIButton!
    @IBOutlet var followButtonSpinner: UIActivityIndicatorView!
    
    var userId: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        followButton.layer.borderWidth = 1
        followButton.layer.cornerRadius = 2
        followButtonSpinner.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profilePictureView.layer.cornerRadius = profilePictureView.width * 0.5
    }
}
