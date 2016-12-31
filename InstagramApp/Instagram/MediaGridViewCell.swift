//
//  MediaGridViewCell.swift
//  Instagram
//
//  Created by Ben Davis on 29/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import UIKit

class MediaGridViewCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    var currentItem: MediaGridViewItem? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentItem = nil
        imageView.image = nil
    }
    
}
