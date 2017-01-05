//
//  MediaGridViewCell.swift
//  Instagram
//
//  Created by Ben Davis on 29/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import UIKit

protocol MediaGridViewCellDelegate: class {
    func mediaGridViewCellWillPrepareForReuse(_ mediaGridViewCell: MediaGridViewCell)
}

@IBDesignable class GradientView: UIView {
    
    var gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.6).cgColor]
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
}

class MediaGridViewCell: UICollectionViewCell {
    
    var currentItem: MediaGridViewItem? = nil
    
    weak var delegate: MediaGridViewCellDelegate? = nil
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var likeImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var gradientView: GradientView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profilePicture.layer.cornerRadius = profilePicture.width*0.5
    }
    
    override func prepareForReuse() {
        delegate?.mediaGridViewCellWillPrepareForReuse(self)
        super.prepareForReuse()
        currentItem = nil
        imageView.image = nil
        profilePicture.image = nil
        likeImage.image = UIImage(named: "heart-outline-white.png")
        username.text = ""
        delegate = nil
    }
    
    @IBAction func likePressed(_ sender: UIButton) {
        likeImage.image = UIImage(named: "heart-red.png")
    }
    
}
