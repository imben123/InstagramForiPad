//
//  ViewController.swift
//  Instagram
//
//  Created by Ben Davis on 29/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import UIKit
import InstagramData
import SDWebImage

class FeedViewController: UIViewController {
    
    var mediaItemTransitioningDelegate: MediaItemViewControllerTransitioningDelegate?

    var dataSource: InstagramFeedDataSource!
    
    var mediaGridView: MediaGridView {
        return view as! MediaGridView
    }
    
    func createLogoutButton() -> UIBarButtonItem {
        let result = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutPressed))
        result.tintColor = Styles.tintColor
        return result
    }
    
    override func loadView() {
        view = MediaGridView()
        dataSource = InstagramFeedDataSource(mediaGridView: mediaGridView)
        mediaGridView.dataSource = dataSource
        mediaGridView.mediaGridViewDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Instagram"
        
        view.backgroundColor = .white
        updateMediaGridView()
        dataSource.updateLatestMedia()
        
        navigationItem.rightBarButtonItem = createLogoutButton()
    }
    
    func updateMediaGridView() {
        mediaGridView.reloadData()
    }
    
    @objc func logoutPressed() {
        InstagramData.shared.authManager.logout()
        navigationController?.setViewControllers([LoginViewController()], animated: true)
    }
    
}

extension FeedViewController: MediaGridViewDelegate {
    
    func mediaGridView(_ sender: MediaGridView, userTappedCellForItem mediaItem: MediaItem, imageView: UIImageView) {
        
        mediaItemTransitioningDelegate = MediaItemViewControllerTransitioningDelegate()
        mediaItemTransitioningDelegate!.imageViewToTransision = imageView

        let viewController = MediaItemViewController(mediaItem: mediaItem,
                                                     dismissalInteractionController: mediaItemTransitioningDelegate!.interactionController)

        viewController.transitioningDelegate = mediaItemTransitioningDelegate
        viewController.modalPresentationStyle = .custom
        
        present(viewController, animated: true)
    }
}
