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
    
    var mediaFeed: MediaFeed
    var dataSource: MediaFeedGridViewDataSource!
    var prefetchingDelegate: MediaFeedPrefetchingDelegate!

    var mediaGridView: MediaGridView!
    var statusLabel: UILabel!
    
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
        
        createMediaDataSource(for: result)
        result.mediaGridViewDataSource = dataSource
        result.dataSource = dataSource
        
        result.mediaGridViewDelegate = self
        result.backgroundColor = .clear
        
        return result
    }
    
    func createMediaDataSource(for gridView: MediaGridView) {
        
        dataSource = MediaFeedGridViewDataSource(mediaFeed: mediaFeed, mediaGridView: gridView)
        dataSource.observer = self
        
        prefetchingDelegate = MediaGridViewPrefetchingDelegate(mediaGridView: gridView,
                                                                     dataSource: dataSource)
        mediaFeed.prefetchingDelegate = prefetchingDelegate
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
        if oldFrame == .zero {
            mediaGridView.frame = view.bounds
            initializeMediaGridView(with: mediaGridView.frame.size)
            mediaGridView.resetScrollPosition(to: IndexPath(item: 0, section: 0))
        }
        
        statusLabel.sizeToFit()
        statusLabel.center = view.center
    }
    
    private func initializeMediaGridView(with contentSize: CGSize) {
        mediaGridView.frame = CGRect(origin: .zero, size: contentSize)
        mediaGridView.contentSize = contentSize
        mediaGridView.contentInset = UIEdgeInsets.init(top: topLayoutGuide.length, left: 0, bottom: 0, right: 0)
        mediaGridView.scrollIndicatorInsets = mediaGridView.contentInset
        mediaGridView.setScrollDirection()
        mediaGridView.updateImageSize()
        mediaGridView.collectionViewLayout.invalidateLayout()
        mediaGridView.setNeedsLayout()
    }
    
    @objc func logoutPressed() {
        InstagramData.shared.logout()
        navigationController?.setViewControllers([LoginViewController()], animated: true)
    }
    
    func profilePictureTapped(forUser user: User) {
        dismiss(animated: true) {
            let userMediaFeedViewController = UserMediaFeedViewController(user: user)
            self.navigationController?.pushViewController(userMediaFeedViewController, animated: true)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        guard let mediaGridView = mediaGridView else {
            return
        }
        
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

extension MediaFeedViewController: MediaFeedGridViewDataSourceObserver {
    
    func mediaGridViewDataSource(_ sender: MediaFeedGridViewDataSource, mediaFeedUpdated itemCount: Int) {
        
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
        
        viewController.onProfilePictureTapped = { [weak self] (user) in
            self?.profilePictureTapped(forUser: user)
        }
        
        present(viewController, animated: true)
    }
    
    @objc func mediaGridView(_ sender: MediaGridView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return sender.flowLayout.itemSize
    }
}
