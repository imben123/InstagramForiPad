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
        
        let cacheKey = SDWebImageManager.shared().cacheKey(for: mediaItem.thumbnail)
        let cachedThumbnail = SDImageCache.shared().imageFromMemoryCache(forKey: cacheKey)
        self.mediaItemView.imageView.image = cachedThumbnail
        
        SDWebImageManager.shared().downloadImage(with: mediaItem.display,
                                                 options: SDWebImageOptions.cacheMemoryOnly,
                                                 progress: nil)
        { [weak self] (image, error, cacheType, finished, url) in

            self?.mediaItemView.imageView.image = image
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
        mediaItemView.imageView.backgroundColor = .black
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
            
            UIView.animate(withDuration: duration,
                           delay: 0,
                           usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0,
                           options: .curveEaseOut,
                           animations: {
                            
                            self.view.transform = .identity
                            self.mediaItemView.commentsView.alpha = 1
                            
            }, completion: { _ in
                self.mediaItemView.imageView.backgroundColor = .clear
                completion()
            })
            
        } else {
            
            let cacheKey = SDWebImageManager.shared().cacheKey(for: mediaItem.thumbnail)
            let cachedThumbnail = SDImageCache.shared().imageFromMemoryCache(forKey: cacheKey)
            UIView.transition(with: self.mediaItemView.imageView,
                              duration: duration,
                              options: .transitionCrossDissolve,
                              animations: { 
                                self.mediaItemView.imageView.image = cachedThumbnail
            }, completion: nil)
            
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: {
                            
                            self.view.transform = self.viewTransformationForPresentation(from: self.originalImageFrame!)
                            self.mediaItemView.commentsView.alpha = 0
                            
            }, completion: { _ in
                completion()
            })
            
        }
    }
    
}
