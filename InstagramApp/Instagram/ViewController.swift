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

class ViewController: UIViewController {
    
    var fetchingMoreMedia = false
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
        mediaGridView.mediaDelegate = self
        mediaGridView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mediaItems = InstagramData.shared.feedManager.media
        updateMediaGridView(with: mediaItems)

        if mediaItems.count == 0 {
            loadMoreMedia()
        }
        
        navigationItem.rightBarButtonItem = createLogoutButton()
    }
    
    func updateMediaGridView(with mediaItems: [MediaItem]) {
        self.mediaGridView.items = mediaItems.map({ (mediaItem) -> MediaGridViewItem in
            return MediaGridViewItem(url: mediaItem.display)
        })
    }
    
    @objc func logoutPressed() {
        InstagramData.shared.authManager.logout()
        self.navigationController?.setViewControllers([LoginViewController()], animated: true)
    }
    
    func loadMoreMedia() {
        guard fetchingMoreMedia == false else {
            return
        }
        fetchingMoreMedia = true
        InstagramData.shared.feedManager.fetchMoreMedia({ [weak self] in
            let mediaItems = InstagramData.shared.feedManager.media
            self?.updateMediaGridView(with: mediaItems)
            self?.fetchingMoreMedia = false
        })
    }
}

extension ViewController: MediaGridViewDelegate {
   
    func mediaGridView(_ sender: MediaGridView, imageForItem item: MediaGridViewItem) -> UIImage? {
        let image = SDImageCache.shared().imageFromMemoryCache(forKey: item.url.absoluteString)
        if let image = image {
            return image
        }
        
        SDWebImageManager.shared().downloadImage(with: item.url, options: [], progress: { (receivedSize, expectedSize) in
            // Nothing
        }, completed: { (image, error, cacheType, finished, url) in
            self.mediaGridView.reloadData()
        })
        
        return nil
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.height {
            loadMoreMedia()
        }
    }
    
}
