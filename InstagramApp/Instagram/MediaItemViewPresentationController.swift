//
//  MediaItemViewPresentationController.swift
//  Instagram
//
//  Created by Ben Davis on 01/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import UIKit

class MediaItemViewPresentationController: UIPresentationController {
    
    fileprivate var dimmingView: UIView!
    
    var mediaItemViewController: MediaItemViewController {
        return presentedViewController as! MediaItemViewController
    }
    
    override var shouldPresentInFullscreen: Bool {
        return false
    }
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        setupDimmingView()
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        return calculateFrameOfPresentedViewInContainerView()
    }
    
    override func presentationTransitionWillBegin() {
        
        containerView?.insertSubview(dimmingView, at: 0)
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        dimmingView.frame = containerView!.bounds
    }
    
}

extension MediaItemViewPresentationController {
    
    func setupDimmingView() {
        dimmingView = UIView()
        dimmingView.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        dimmingView.alpha = 0.0
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        dimmingView.addGestureRecognizer(recognizer)
    }
    
    dynamic func handleTap(recognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }
    
    func calculateFrameOfPresentedViewInContainerView() -> CGRect {
        let frameOfPresentingViewController = presentingViewController.view.frame
        let boundingSize = boundingSizeOfMediaItemViewController()
        let size = mediaItemViewController.preferredSize(thatFits: boundingSize)
        let result = CGRect(x: frameOfPresentingViewController.width*0.5 - size.width*0.5,
                            y: frameOfPresentingViewController.height*0.5 - size.height*0.5,
                            width: size.width,
                            height: size.height)
        return result
    }
    
    func boundingSizeOfMediaItemViewController() -> CGSize {
        let frameOfPresentingViewController = presentingViewController.view.frame
        
        let minWidth: CGFloat = 375
        let minHeight: CGFloat = 667
        let preferredMargin: CGFloat = 44
        
        let boundingWidth = max(frameOfPresentingViewController.size.width - preferredMargin, minWidth)
        let boundingHeight = max(frameOfPresentingViewController.size.height - preferredMargin, minHeight)
        
        return CGSize(width: boundingWidth, height: boundingHeight)
    }
    
}
