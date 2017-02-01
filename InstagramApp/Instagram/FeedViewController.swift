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
        
        view.backgroundColor = .black
        updateMediaGridView()
        dataSource.loadMoreMedia()
        
        navigationItem.rightBarButtonItem = createLogoutButton()
    }
    
    func updateMediaGridView() {
        self.mediaGridView.reloadData()
    }
    
    @objc func logoutPressed() {
        InstagramData.shared.authManager.logout()
        self.navigationController?.setViewControllers([LoginViewController()], animated: true)
    }
    
    var imageViewToTransision: UIImageView?
}

extension FeedViewController: MediaGridViewDelegate {
    func mediaGridView(_ sender: MediaGridView, userTappedCellForItem mediaItem: MediaItem, imageView: UIImageView) {
        imageViewToTransision = imageView
        let viewController = MediaItemViewController(mediaItem: mediaItem)
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self
        present(viewController, animated: true)
    }
}

extension FeedViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return MediaItemViewAnimatedTransitioning(initialImageView: imageViewToTransision!, direction: .present)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return MediaItemViewAnimatedTransitioning(initialImageView: imageViewToTransision!, direction: .dismiss)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return MediaItemViewPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}
