//
//  MediaItemViewAnimatedTransitioning.swift
//  Instagram
//
//  Created by Ben Davis on 01/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import UIKit

class MediaItemViewAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    let initialImageView: UIImageView?
    let direction: MediaItemViewTransitioningDirection
    
    init(initialImageView: UIImageView?, direction: MediaItemViewTransitioningDirection) {
        self.initialImageView = initialImageView
        self.direction = direction
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if direction == .present {
            return 0.4
        } else {
            return 0.3
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let mediaItemViewController: MediaItemViewController
        if direction == .present {
            mediaItemViewController = transitionContext.viewController(forKey: .to) as! MediaItemViewController
        } else {
            mediaItemViewController = transitionContext.viewController(forKey: .from) as! MediaItemViewController
        }
        
        let imageStartFrame = self.imageStartFrame(in: transitionContext)

        if direction == .present {
            mediaItemViewController.view.frame = transitionContext.finalFrame(for: mediaItemViewController)
            mediaItemViewController.prepareForPresentation(from: imageStartFrame)
            transitionContext.containerView.addSubview(mediaItemViewController.view)
        }
        
        let duration = transitionDuration(using: transitionContext)
        mediaItemViewController.performTransition(with: duration,
                                                  direction: direction,
                                                  fromFrame: imageStartFrame) { completed in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    private func imageStartFrame(in transitionContext: UIViewControllerContextTransitioning) -> CGRect {
        if let initialImageView = initialImageView {
            return transitionContext.containerView.convert(initialImageView.frame,
                                                           from: initialImageView.superview)
        } else {
            return .zero
        }
    }
}
