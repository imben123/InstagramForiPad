//
//  MainFeedViewController.swift
//  Instagram
//
//  Created by Ben Davis on 26/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import UIKit
import InstagramData

class MainFeedViewController: MediaFeedViewController {
    
    init() {
        super.init(mediaFeed: InstagramData.shared.userFeedMediaFeed)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Instagram"
        navigationItem.rightBarButtonItem = createLogoutButton()
    }
    
    override func createMediaGridView(contentSize: CGSize) -> MediaGridView {
        let result = super.createMediaGridView(contentSize: contentSize)
        dataSource.userActionDelegate = self
        return result
    }
    
    func createLogoutButton() -> UIBarButtonItem {
        let result = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutPressed))
        result.tintColor = Styles.tintColor
        return result
    }
}

extension MainFeedViewController: MediaFeedDataSourceUserActionDelegate {
    
    func mediaFeedDataSource(_ sender: MediaFeedDataSource, userPressOwnerOfMediaItem mediaItem: MediaItem) {
        let user = mediaItem.owner
        let viewController = UserMediaFeedViewController(userId: user.id, username: user.username)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}
