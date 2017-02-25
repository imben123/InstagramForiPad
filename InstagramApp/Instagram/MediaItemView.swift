//
//  MediaItemView.swift
//  Instagram
//
//  Created by Ben Davis on 29/01/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import UIKit
import InstagramData

func maxSize(_ first: CGSize, second: CGSize) -> CGSize {
    return CGSize(width: max(first.width, second.width),
                  height: max(first.height, second.height))
}

func minSize(_ first: CGSize, second: CGSize) -> CGSize {
    return CGSize(width: min(first.width, second.width),
                  height: min(first.height, second.height))
}

func proportionalSize(_ size: CGSize, thatFits constrainingSize: CGSize) -> CGSize {
    
    let heightRatio = min(1, (constrainingSize.height / size.height))
    let widthRatio = min(1, (constrainingSize.width / size.width))
    
    let ratio = min(heightRatio, widthRatio)
    
    return CGSize(width: size.width * ratio,
                  height: size.height * ratio)
}

protocol MediaItemViewDismissalDelegate: class {
    func handlePanGesture(_ sender: UIPanGestureRecognizer)
}

class MediaItemView: UIView {
    
    weak var dismissalDelegate: MediaItemViewDismissalDelegate?
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var commentsView: MediaCommentsView!
    @IBOutlet var commentsViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var imageViewHeightConstraint: NSLayoutConstraint!
    
    var mediaItem: MediaItem? {
        didSet {
            if let newValue = mediaItem {
                commentsView.setComments(newValue)
                updateImageViewHeightConstraint()
            }
        }
    }
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    override var frame: CGRect {
        didSet {
            updateImageViewHeightConstraint()
        }
    }
    
    func updateImageViewHeightConstraint() {
        imageViewHeightConstraint?.constant = calculateImageViewHeight()
    }
    
    func calculateImageViewHeight() -> CGFloat {
        if let mediaItem = mediaItem {
            return mediaItem.dimensions.height * (width / mediaItem.dimensions.width)
        }
        return 0
    }
    
    private var commentsViewWidth: CGFloat {
        if traitCollection.horizontalSizeClass != .compact {
            return commentsViewWidthConstraint.constant
        }
        return 0
    }
    
    func calculateImageViewSize() -> CGSize {
        if traitCollection.horizontalSizeClass == .regular {
            return CGSize(width: width - commentsViewWidth, height: height)
        } else {
            let imageHeight = calculateImageViewHeight()
            return CGSize(width: width, height: imageHeight)
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        frame = CGRect(x: originX, y: originY, width: size.width, height: size.height)
        
        if let mediaItem = mediaItem {
            
            let imageSize = proportionalSize(mediaItem.dimensions,
                                             thatFits: CGSize(width: size.width - commentsViewWidth,
                                                              height: size.height))
            
            if traitCollection.horizontalSizeClass == .compact {
                
                return CGSize(width: imageSize.width, height: size.height)

            } else {
                
                return CGSize(width: imageSize.width + commentsViewWidth,
                              height: imageSize.height)

            }
        }
        
        return .zero
    }
    
}

extension MediaItemView {
    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        self.dismissalDelegate?.handlePanGesture(sender)
    }
}
