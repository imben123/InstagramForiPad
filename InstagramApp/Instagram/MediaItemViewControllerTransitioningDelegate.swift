//
//  MediaItemViewControllerTransitioningDelegate.swift
//  Instagram
//
//  Created by Ben Davis on 11/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import UIKit

class PercentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition {
    var hasStarted = false
}

class MediaItemViewControllerTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    var imageViewToTransision: (()->UIImageView?)? = nil
    let interactionController = PercentDrivenInteractiveTransition()
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return MediaItemViewAnimatedTransitioning(initialImageView: imageViewToTransision!(), direction: .present)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return MediaItemViewAnimatedTransitioning(initialImageView: imageViewToTransision!(), direction: .dismiss)
    }
    
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        
        return MediaItemViewPresentationController(presentedViewController: presented, presenting: source)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            
            return interactionController.hasStarted ? interactionController : nil
    }
    
}
