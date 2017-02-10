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
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let frameOfPresentingViewController = presentingViewController.view.frame
        let boundingSize = CGSize(width: frameOfPresentingViewController.size.width - 44,
                                  height: frameOfPresentingViewController.size.height - 44)
        let size = mediaItemViewController.preferredSize(thatFits: boundingSize)
        let result = CGRect(x: frameOfPresentingViewController.width*0.5 - size.width*0.5,
                            y: frameOfPresentingViewController.height*0.5 - size.height*0.5,
                            width: size.width,
                            height: size.height)
        return result
    }
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentedViewController)
        setupDimmingView()
    }
    
    func setupDimmingView() {
        dimmingView = UIView()
        dimmingView.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        dimmingView.alpha = 0.0
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        dimmingView.addGestureRecognizer(recognizer)
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
    
    dynamic func handleTap(recognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        dimmingView.frame = containerView!.bounds
    }
    
}
