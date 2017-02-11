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
    var openMediaItem: MediaItem?
    
    var dataSource: InstagramFeedDataSource!
    
    var mediaGridView: MediaGridView!
    
    func createLogoutButton() -> UIBarButtonItem {
        let result = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutPressed))
        result.tintColor = Styles.tintColor
        return result
    }
    
    override func loadView() {
        view = UIView()
        mediaGridView = createMediaGridView(contentSize: .zero)
        view.addSubview(mediaGridView)
    }
    
    func createMediaGridView(contentSize: CGSize) -> MediaGridView {
        let result = MediaGridView()
        dataSource = InstagramFeedDataSource(mediaGridView: result)
        result.dataSource = dataSource
        result.mediaGridViewDelegate = self
        result.backgroundColor = .white
        return result
    }
    
    func initializeMediaGridView(with contentSize: CGSize) {
        mediaGridView.frame = view.bounds
        mediaGridView.contentInset = UIEdgeInsetsMake(topLayoutGuide.length, 0, 0, 0)
        mediaGridView.contentSize = contentSize
        mediaGridView.setScrollDirection()
        mediaGridView.updateImageSize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Instagram"
        
        updateMediaGridView()
        dataSource.updateLatestMedia()
        
        navigationItem.rightBarButtonItem = createLogoutButton()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let oldFrame = mediaGridView.frame
        mediaGridView.frame = view.bounds
        if oldFrame == .zero {
            initializeMediaGridView(with: mediaGridView.frame.size)
        }
    }
    
    func updateMediaGridView() {
        mediaGridView.reloadData()
    }
    
    @objc func logoutPressed() {
        InstagramData.shared.authManager.logout()
        navigationController?.setViewControllers([LoginViewController()], animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let currentOffset = mediaGridView.firstVisibleIndexPath()
        DispatchQueue.main.async {
            self.mediaGridView.removeFromSuperview()
            self.mediaGridView = self.createMediaGridView(contentSize: size)
            self.initializeMediaGridView(with: size)
            self.mediaGridView.resetScrollPosition(to: currentOffset)
            self.view.addSubview(self.mediaGridView)
        }
    }
}

extension FeedViewController: MediaGridViewDelegate {
    
    func mediaGridView(_ sender: MediaGridView, userTappedCellForItem mediaItem: MediaItem, imageView: UIImageView) {
        
        mediaItemTransitioningDelegate = MediaItemViewControllerTransitioningDelegate()
        mediaItemTransitioningDelegate!.imageViewToTransision = {
            return self.mediaGridView.imageViewForMediaItem(self.openMediaItem!)

        }
        openMediaItem = mediaItem
        
        let viewController = MediaItemViewController(mediaItem: mediaItem,
                                                     dismissalInteractionController: mediaItemTransitioningDelegate!.interactionController)

        viewController.transitioningDelegate = mediaItemTransitioningDelegate
        viewController.modalPresentationStyle = .custom
        
        present(viewController, animated: true)
    }
}
