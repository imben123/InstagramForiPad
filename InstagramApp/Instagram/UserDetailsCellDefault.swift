//
//  UserDetailsView.swift
//  Instagram
//
//  Created by Ben Davis on 16/04/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import UIKit

class UserDetailsCellDefault: UserDetailsCell {
    
    @IBOutlet private var imageCenterAlign: NSLayoutConstraint!
    @IBOutlet private var imageTopEdgeToContainer: NSLayoutConstraint!
    @IBOutlet private var usernameUnderImage: NSLayoutConstraint!
    @IBOutlet private var usernameCenterAlign: NSLayoutConstraint!
    @IBOutlet private var followsCenterAlign: NSLayoutConstraint!
    @IBOutlet private var followsRightEdgeToContainer: NSLayoutConstraint!
    @IBOutlet private var followsLeftEdgeToContainer: NSLayoutConstraint!
    @IBOutlet private var followButtonCenterAlign: NSLayoutConstraint!
    @IBOutlet private var bioUnderFollowButton: NSLayoutConstraint!
    @IBOutlet private var bioLeftEdgeToContainer: NSLayoutConstraint!
    
    @IBOutlet private var usernameWidth: NSLayoutConstraint!
    @IBOutlet private var imageCenterVertically: NSLayoutConstraint!
    @IBOutlet private var imageLeftEdgeToContainer: NSLayoutConstraint!
    @IBOutlet private var usernameAlignTopToImage: NSLayoutConstraint!
    @IBOutlet private var usernameLeftEdgeToImage: NSLayoutConstraint!
    @IBOutlet private var followsLeftEdgeToImage: NSLayoutConstraint!
    @IBOutlet private var bioLeftEdgeToFollows: NSLayoutConstraint!
    @IBOutlet private var bioTopAlignUsernameTop: NSLayoutConstraint!
    
    override func layoutSubviews() {
        activateCorrectContraints()
        super.layoutSubviews()
    }
    
    private func activateCorrectContraints() {
        swapConstraints(forPortrait: width < 550)
    }
    
    private func swapConstraints(forPortrait portrait: Bool) {
        
        guard imageCenterAlign != nil else {
            return
        }
        
        imageCenterAlign.isActive = portrait
        imageTopEdgeToContainer.isActive = portrait
        usernameUnderImage.isActive = portrait
        usernameCenterAlign.isActive = portrait
        followsCenterAlign.isActive = portrait
        followsRightEdgeToContainer.isActive = portrait
        followsLeftEdgeToContainer.isActive = portrait
        followButtonCenterAlign.isActive = portrait
        bioUnderFollowButton.isActive = portrait
        bioLeftEdgeToContainer.isActive = portrait
        
        usernameWidth.isActive = !portrait
        imageCenterVertically.isActive = !portrait
        imageLeftEdgeToContainer.isActive = !portrait
        usernameAlignTopToImage.isActive = !portrait
        usernameLeftEdgeToImage.isActive = !portrait
        followsLeftEdgeToImage.isActive = !portrait
        bioLeftEdgeToFollows.isActive = !portrait
        bioTopAlignUsernameTop.isActive = !portrait
        
    }
}
