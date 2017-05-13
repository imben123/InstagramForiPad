//
//  UserMediaFeedViewController.swift
//  Instagram
//
//  Created by Ben Davis on 02/03/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import Foundation
import InstagramData
import SwiftToolbox

class UserMediaFeedViewController: MediaFeedViewController {
    
    let user: User
    
    var multiSectionDataSource: MultiSectionDataSource!
    let userDetailsCellDataSource: UserDetailsCellDataSource
    
    init(user: User) {
        self.user = user
        self.userDetailsCellDataSource =
            UserDetailsCellDataSource(user: user, followRequestsManager: InstagramData.shared.followRequestsManager)
        super.init(mediaFeed: InstagramData.shared.createUserProfileMediaFeed(for: user.id))
        
        updateUserDetails()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = user.username
    }
    
    // MARK: - Update user
    
    private func updateUserDetails() {
        InstagramData.shared.usersDataStore.fetchUser(for: user.id, forceUpdate: true) { [weak self] (updatedUser) in
            if let updatedUser = updatedUser {
                self?.userDetailsCellDataSource.user = updatedUser
                self?.mediaGridView.reloadSections([0])
            }
        }
    }
    
    // MARK: -
    
    override func profilePictureTapped(forUser user: User) {
        if user.id != self.user.id {
            super.profilePictureTapped(forUser: user)
        } else {
            dismiss(animated: true)
        }
    }
    
    override func createMediaGridView(contentSize: CGSize) -> MediaGridView {
        
        let result = super.createMediaGridView(contentSize: contentSize)
        
        dataSource.section = 1
        
        result.register(UINib(nibName: "UserDetailsCellDefault", bundle: nil),
                        forCellWithReuseIdentifier: "UserDetailsCellDefault")
        
        result.register(UINib(nibName: "UserDetailsCellCompact", bundle: nil),
                        forCellWithReuseIdentifier: "UserDetailsCellCompact")
        
        multiSectionDataSource = MultiSectionDataSource(sections: [userDetailsCellDataSource, dataSource])
        
        result.dataSource = multiSectionDataSource
        
        return result
    }
    
    override func mediaGridView(_ sender: MediaGridView,
                                layout collectionViewLayout: UICollectionViewLayout,
                                sizeForItemAt indexPath: IndexPath) -> CGSize {
                
        if indexPath.section == 0 {
            
            if sender.flowLayout.scrollDirection == .horizontal {
                let height = sender.height - sender.contentInset.top - sender.contentInset.bottom
                return CGSize(width: 250, height: height)
            } else {
                let width = sender.width - sender.contentInset.left - sender.contentInset.right
                return CGSize(width: width, height: 220)
            }
        }
        
        return sender.flowLayout.itemSize
    }
    
}
