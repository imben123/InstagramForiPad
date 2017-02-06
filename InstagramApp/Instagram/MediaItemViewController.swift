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

enum MediaItemViewTransitioningDirection {
    case present
    case dismiss
}

class MediaItemViewController: UIViewController {
    
    let mediaItem: MediaItem
    var originalImageFrame: CGRect?

    var mediaItemView: MediaItemView!
    var gotFullResolutionImage = false
    
    init(mediaItem: MediaItem) {
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
        view = mediaItemView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mediaItemView.imageView.image = getThumbnailFromCache()
        
        if getDisplayImageFromCache() == nil {
            downloadDisplayImage()
        } else {
            gotFullResolutionImage = true
        }
    }
    
    private func downloadDisplayImage() {
        SDWebImageManager.shared().downloadImage(with: mediaItem.display,
                                                 options: SDWebImageOptions.highPriority,
                                                 progress: nil)
        { [weak self] (image, error, cacheType, finished, url) in
            
            if let image = image {
                self?.gotFullResolutionImage = true
                self?.crossDisolveImageView(to: image, duration: 0.3)
            }
        }
    }
    
    func preferredSize(thatFits size: CGSize) -> CGSize {
        let boundingSize = size //minSize(size, second: view.frame.size)
        return mediaItemView.sizeThatFits(boundingSize)
    }
    
    func prepareForPresentation(from imageFrame:CGRect) {
        originalImageFrame = imageFrame
        view.transform = viewTransformationForPresentation(from: imageFrame)
        mediaItemView.commentsView.alpha = 0
        mediaItemView.backgroundView.alpha = 0
    }
    
    func viewTransformationForPresentation(from imageFrame:CGRect) -> CGAffineTransform {
        
        let imageViewSize = mediaItemView.calculateImageViewSize()
        
        let scale: CGFloat
        if imageViewSize.height < imageViewSize.width {
            scale = imageFrame.height / imageViewSize.height
        } else {
            scale = imageFrame.width / imageViewSize.width
        }
        
        let originXAfterScale = view.originX + ((view.width - (view.width * scale)) * 0.5)
        let originYAfterScale = view.originY + ((view.height - (view.height * scale)) * 0.5)
        
        let centerXAfterScale = originXAfterScale + (imageViewSize.width * scale * 0.5)
        let centerYAfterScale = originYAfterScale + (imageViewSize.height * scale * 0.5)

        let imageCenterX = imageFrame.origin.x + (imageFrame.width * 0.5)
        let imageCenterY = imageFrame.origin.y + (imageFrame.height * 0.5)
        
        let offsetX = imageCenterX - centerXAfterScale
        let offsetY = imageCenterY - centerYAfterScale
        
        return CGAffineTransform(scaleX: scale, y: scale)
            .translatedBy(x: offsetX / scale,
                          y: offsetY / scale)
    }
    
    func performTransition(with duration: TimeInterval,
                           direction: MediaItemViewTransitioningDirection,
                           completion: @escaping ()->()) {
        
        if direction == .present {
            
            performOpeningBounceAnimation(duration, completion: completion)

            if let cachedDisplayImage = getDisplayImageFromCache() {
                crossDisolveImageView(to: cachedDisplayImage, duration: duration)
            }
            
        } else {
            
            if self.gotFullResolutionImage {
                self.mediaItemView.backgroundView.alpha = 0
            }
            
            let cachedThumbnail = getThumbnailFromCache()!
            crossDisolveImageView(to: cachedThumbnail, duration: duration)
            performDismissalAnimation(duration, completion: completion)
        }
    }
    
    private func crossDisolveImageView(to image: UIImage, duration: TimeInterval) {
        UIView.transition(with: self.mediaItemView.imageView,
                          duration: duration,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.mediaItemView.imageView.image = image
        }, completion: nil)
    }
    
    private func performOpeningBounceAnimation(_ duration: TimeInterval, completion: @escaping ()->()) {
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0,
                       options: .curveEaseOut,
                       animations: {
                        
                        self.view.transform = .identity
                        self.mediaItemView.commentsView.alpha = 1
                        self.mediaItemView.backgroundView.alpha = 1
                        
        }, completion: { _ in
            completion()
        })
    }
    
    private func performDismissalAnimation(_ duration: TimeInterval, completion: @escaping ()->()) {
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        
                        self.view.transform = self.viewTransformationForPresentation(from: self.originalImageFrame!)
                        self.mediaItemView.commentsView.alpha = 0
                        self.mediaItemView.backgroundView.alpha = 0
                        
        }, completion: { _ in
            completion()
        })
    }
    
    private func getThumbnailFromCache() -> UIImage? {
        return self.getImageFromCache(mediaItem.thumbnail)
    }
    
    private func getDisplayImageFromCache() -> UIImage? {
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
