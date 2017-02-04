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

class MediaItemView: UIView {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var commentsView: MediaCommentsView!
    @IBOutlet var commentsViewWidthConstraint: NSLayoutConstraint!
    
    var mediaItem: MediaItem? {
        didSet {
            if let newValue = mediaItem {
                commentsView.setComments(newValue)
            }
        }
    }
    
    func calculateImageViewSize() -> CGSize {
        return CGSize(width: width - commentsViewWidthConstraint.constant, height: height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        if let mediaItem = mediaItem {
            
            let imageSize = proportionalSize(mediaItem.dimensions,
                                             thatFits: CGSize(width: size.width - commentsView.width,
                                                              height: size.height))
            
            let preferredSize = CGSize(width: imageSize.width + commentsView.width,
                                       height: imageSize.height)
            
            return preferredSize
        }
        
        return .zero
    }
    
}
