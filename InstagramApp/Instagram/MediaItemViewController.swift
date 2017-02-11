//
//  MediaItemViewController.swift
//  Instagram
//
//  Created by Ben Davis on 29/01/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import UIKit
import InstagramData
import SDWebImage

class PercentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition {
    var hasStarted = false
}

enum MediaItemViewTransitioningDirection {
    case present
    case dismiss
}

class MediaItemViewController: UIViewController {
    
    var dismissalInteractionController: PercentDrivenInteractiveTransition?

    let mediaItem: MediaItem

    var mediaItemView: MediaItemView!
    var gotFullResolutionImage = false
    
    init(mediaItem: MediaItem, dismissalInteractionController: PercentDrivenInteractiveTransition?) {
        self.dismissalInteractionController = dismissalInteractionController
        self.mediaItem = mediaItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        let nib = Bundle.main.loadNibNamed("MediaItemView", owner: nil, options: [:])!
        mediaItemView = nib.first as! MediaItemView
        mediaItemView.mediaItem = mediaItem
        mediaItemView.dismissalDelegate = self
        view = mediaItemView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mediaItemView.image = getThumbnailFromCache()
        
        if getDisplayImageFromCache() == nil {
            downloadDisplayImage()
        } else {
            gotFullResolutionImage = true
        }
        
        InstagramData.shared.mediaManager.updateMediaItem(mediaItem) { (updatedMediaItem) in
            self.mediaItemView.commentsView.setComments(updatedMediaItem)
        }
    }
    
    func preferredSize(thatFits size: CGSize) -> CGSize {
        let boundingSize = size //minSize(size, second: view.frame.size)
        return mediaItemView.sizeThatFits(boundingSize)
    }
    
}

extension MediaItemViewController {
    
    fileprivate func downloadDisplayImage() {
        SDWebImageManager.shared().downloadImage(with: mediaItem.display,
                                                 options: SDWebImageOptions.highPriority,
                                                 progress: nil)
        { [weak self] (image, error, cacheType, finished, url) in
            
            if let image = image {
                self?.gotFullResolutionImage = true
                self?.crossDisolveImageView(to: image, duration: 0.1)
            }
        }
    }
    
    func getThumbnailFromCache() -> UIImage? {
        return self.getImageFromCache(mediaItem.thumbnail)
    }
    
    func getDisplayImageFromCache() -> UIImage? {
        return self.getImageFromCache(mediaItem.display)
    }
    
    private func getImageFromCache(_ url: URL) -> UIImage? {
        let cacheKey = SDWebImageManager.shared().cacheKey(for: url)
        let cachedImage = SDImageCache.shared().imageFromMemoryCache(forKey: cacheKey)
        if cachedImage == nil {
            let cachedImage = SDImageCache.shared().imageFromDiskCache(forKey: cacheKey)
            return cachedImage
        }
        return cachedImage
    }
}
