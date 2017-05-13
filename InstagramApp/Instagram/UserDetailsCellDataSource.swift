//
//  UserDetailsCellDataSource.swift
//  Instagram
//
//  Created by Ben Davis on 16/04/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import UIKit
import InstagramData

class UserDetailsCellDataSource: NSObject, UICollectionViewDataSource {
    
    var user: User {
        didSet {
            usingInitialUser = false
        }
    }
    private let followRequestsManager: FollowRequestsManager
    private var usingInitialUser = true
    
    private weak var cell: UserDetailsCellContents?
    
    init(user: User, followRequestsManager: FollowRequestsManager) {
        self.user = user
        self.followRequestsManager = followRequestsManager
        super.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: UserDetailsCellContents
        
        if collectionViewCellIsCompactWidth(collectionView, atIndexPath: indexPath) {
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserDetailsCellCompact",
                                                      for: indexPath) as! UserDetailsCellContents
        
        } else {
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserDetailsCellDefault",
                                                      for: indexPath) as! UserDetailsCellContents
            
        }
        
        cell.setUser(user, followingStateKnown: !usingInitialUser)
        
        if user.followedByViewer {
            cell.followButton.addTarget(self, action: #selector(unfollowUserPressed(in:)), for: .touchUpInside)
        } else {
            cell.followButton.addTarget(self, action: #selector(followUserPressed(in:)), for: .touchUpInside)
        }
        
        self.cell = cell
        return cell as! UICollectionViewCell
    }
    
    private func collectionViewCellIsCompactWidth(_ collectionView: UICollectionView,
                                                  atIndexPath indexPath: IndexPath) -> Bool {
        
        if let flowDelegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
            let itemSize = flowDelegate.collectionView?(collectionView,
                                                        layout: collectionView.collectionViewLayout,
                                                        sizeForItemAt: indexPath) {
            
            return max(itemSize.width, itemSize.height) < 550
            
        } else {
            return false
        }
    }
    
    @objc private func followUserPressed(in button: UIButton) {
        startCellFollowAnimating()
        self.followRequestsManager.followUser(with: user.id) { [weak self] in
            self?.updateCellFollowState()
        }
    }
    
    @objc private func unfollowUserPressed(in button: UIButton) {
        startCellFollowAnimating()
        self.followRequestsManager.unfollowUser(with: user.id) { [weak self] in
            self?.updateCellFollowState()
        }
    }
    
    private func startCellFollowAnimating() {
        cell?.followButtonSpinner.isHidden = false
        cell?.followButton.alpha = 0.6
        cell?.followButtonSpinner.startAnimating()
    }
    
    private func stopCellFollowAnimating() {
        cell?.followButtonSpinner.isHidden = true
        cell?.followButton.alpha = 1
        cell?.followButtonSpinner.stopAnimating()
    }
    
    private func updateCellFollowState() {
        stopCellFollowAnimating()
        user.followedByViewer = !user.followedByViewer
        cell?.setUser(user, followingStateKnown: true)
    }
}
