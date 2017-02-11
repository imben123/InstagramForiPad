//
//  MediaItemViewControllerTransitions.swift
//  Instagram
//
//  Created by Ben Davis on 11/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import UIKit

extension MediaItemViewController {
    
    func prepareForPresentation(from imageFrame:CGRect) {
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
                           fromFrame: CGRect,
                           completion: @escaping (_ completed: Bool)->()) {
        
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
            performDismissalAnimation(duration, fromFrame: fromFrame, completion: { (completed) in
                
                // Put this back incase the animation was cancelled
                let displayImage = self.getDisplayImageFromCache()!
                self.crossDisolveImageView(to: displayImage, duration: 0.2)
                
                completion(completed)
            })
        }
    }
    
    func crossDisolveImageView(to image: UIImage, duration: TimeInterval) {
        UIView.transition(with: self.mediaItemView.imageView,
                          duration: duration,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.mediaItemView.image = image
        }, completion: nil)
    }
    
    private func performOpeningBounceAnimation(_ duration: TimeInterval, completion: @escaping (_ completed: Bool)->()) {
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0,
                       options: .curveEaseOut,
                       animations: {
                        
                        self.view.transform = .identity
                        self.mediaItemView.commentsView.alpha = 1
                        self.mediaItemView.backgroundView.alpha = 1
                        
        }, completion: completion)
    }
    
    private func performDismissalAnimation(_ duration: TimeInterval,
                                           fromFrame: CGRect,
                                           completion: @escaping (_ completed: Bool)->()) {
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        
                        self.view.transform = self.viewTransformationForPresentation(from: fromFrame)
                        self.mediaItemView.commentsView.alpha = 0
                        self.mediaItemView.backgroundView.alpha = 0
                        
        }, completion: completion)
    }
    
}
