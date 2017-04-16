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

class MediaFeedViewController: UIViewController {
    
    private var mediaFeed: MediaFeed
    var dataSource: MediaFeedDataSource!
    fileprivate var mediaGridView: MediaGridView!
    fileprivate var statusLabel: UILabel!
    
    fileprivate var mediaItemTransitioningDelegate: MediaItemViewControllerTransitioningDelegate?
    fileprivate var openMediaItem: MediaItem?

    init(mediaFeed: MediaFeed) {
        self.mediaFeed = mediaFeed
        super.init(nibName: nil, bundle: nil)
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        
        view = UIView()
        view.backgroundColor = .white
        
        statusLabel = createstatusLabel()
        view.addSubview(statusLabel)

        mediaGridView = createMediaGridView(contentSize: .zero)
        view.addSubview(mediaGridView)
    }
    
    func createMediaGridView(contentSize: CGSize) -> MediaGridView {
        let result = MediaGridView()
        result.dataSource = createMediaDataSource(for: result)
        result.mediaGridViewDelegate = self
        result.backgroundColor = .clear
        return result
    }
    
    func createMediaDataSource(for gridView: MediaGridView) -> MediaFeedDataSource {
        dataSource = MediaFeedDataSource(mediaFeed: mediaFeed, mediaGridView: gridView)
        dataSource.observer = self
        return dataSource
    }
    
    func createstatusLabel() -> UILabel {
        let result = UILabel()
        result.text = "Loading media..."
        
        if mediaFeed.mediaCount > 0 {
            result.isHidden = true
        }
        
        return result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mediaGridView.reloadData()
        dataSource.updateLatestMedia()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let oldFrame = mediaGridView.frame
        mediaGridView.frame = view.bounds
        if oldFrame == .zero {
            initializeMediaGridView(with: mediaGridView.frame.size)
        }
        
        statusLabel.sizeToFit()
        statusLabel.center = view.center
    }
    
    private func initializeMediaGridView(with contentSize: CGSize) {
        mediaGridView.frame = CGRect(origin: .zero, size: contentSize)
        mediaGridView.contentSize = contentSize
        mediaGridView.contentInset = UIEdgeInsetsMake(topLayoutGuide.length, 0, 0, 0)
        mediaGridView.setScrollDirection()
        mediaGridView.updateImageSize()
        mediaGridView.collectionViewLayout.invalidateLayout()
        mediaGridView.setNeedsLayout()
    }
    
    @objc func logoutPressed() {
        InstagramData.shared.logout()
        navigationController?.setViewControllers([LoginViewController()], animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let currentOffset = mediaGridView.firstVisibleIndexPath()
        DispatchQueue.main.async {
            self.resetMediaGridView(with: size, offset: currentOffset)
        }
    }
    
    private func resetMediaGridView(with size: CGSize, offset: IndexPath?) {
        
        mediaGridView.dataSource = nil
        mediaGridView.mediaGridViewDelegate = nil
        mediaGridView.removeFromSuperview()
        
        mediaGridView = createMediaGridView(contentSize: size)
        initializeMediaGridView(with: size)
        mediaGridView.resetScrollPosition(to: offset)
        
        view.addSubview(mediaGridView)
    }
}

extension MediaFeedViewController: MediaFeedDataSourceObserver {
    
    func mediaFeedDataSource(_ sender: MediaFeedDataSource, mediaFeedUpdated itemCount: Int) {
        
        if itemCount == 0 {
            statusLabel.text = "No media to display"
            view.setNeedsLayout()
        } else {
            statusLabel.isHidden = true
        }
    }
}

extension MediaFeedViewController: MediaGridViewDelegate {
    
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
        
        viewController.onProfilePictureTapped = { [weak self] (userId, username) in
            self?.profilePictureTapped(forUserWithId: userId, username: username)
        }
        
        present(viewController, animated: true)
    }
    
    func profilePictureTapped(forUserWithId userId: String, username: String) {
        dismiss(animated: true) {
            let userMediaFeedViewController = UserMediaFeedViewController(userId: userId, username: username)
            self.navigationController?.pushViewController(userMediaFeedViewController, animated: true)
        }
    }
}
