//
//  MediaItemViewControllerInteractiveDismissal.swift
//  Instagram
//
//  Created by Ben Davis on 11/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import UIKit

extension MediaItemViewController: MediaItemViewDismissalDelegate {
    
    func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        
        let percentThreshold: CGFloat = 0.3
        let maximumMovement: CGFloat = 500
        
        let translation = sender.translation(in: view)
        
        let translationDistance = CGFloat( sqrtf( Float(
            (translation.x*translation.x) + (translation.y*translation.y)
        )))
        
        let progress = abs(translationDistance)
        let progressPercent = min((progress / maximumMovement), 1)
        
        guard let interactor = dismissalInteractionController else { return }
        
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.update(progressPercent)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            if interactor.percentComplete > percentThreshold {
                interactor.finish()
            } else {
                if let displayImage = getDisplayImageFromCache() {
                    crossDisolveImageView(to: displayImage, duration: 0.2)
                }
                
                // The dispatch is needed so that it doesn't interrupt the image cross-disolve
                DispatchQueue.main.async {
                    interactor.cancel()
                }
            }
        default:
            break
        }
    }
    
}
