//
//  MediaCommentsView.swift
//  Instagram
//
//  Created by Ben Davis on 01/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import UIKit
import InstagramData
import SDWebImage

class MediaCommentsView: UIView {
    
    fileprivate var tableView: UITableView?
    fileprivate var comments: [MediaItemComment]!
    fileprivate var initialComment: String?
    fileprivate var usernameOfOwner: String?
    fileprivate var profilePictureOfOwner: URL?
    
    fileprivate struct Constants {
        static let cellReuseIdentifier: String = "MediaCommentsViewCell"
        static let minCellHeight: CGFloat = 48
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView?.frame = bounds
    }
    
    func setComments(_ comments: [MediaItemComment],
                     initialComment: String? = nil,
                     usernameOfOwner: String? = nil,
                     profilePictureOfOwner: URL? = nil) {
        
        self.comments = comments
        self.initialComment = initialComment
        self.usernameOfOwner = usernameOfOwner
        self.profilePictureOfOwner = profilePictureOfOwner
        
        tableView = UITableView(frame: .zero, style: .plain)
        let nib = UINib(nibName: "MediaCommentsViewCell", bundle: nil)
        tableView!.register(nib, forCellReuseIdentifier: Constants.cellReuseIdentifier)
        tableView!.delegate = self
        tableView!.dataSource = self
        tableView!.allowsSelection = false
        tableView!.rowHeight = UITableViewAutomaticDimension
        tableView!.estimatedRowHeight = 140
        tableView!.tableFooterView = UIView()
        tableView!.backgroundColor = .clear
        addSubview(tableView!)
    }
}

extension MediaCommentsView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if initialComment != nil {
            return comments.count + 1
        } else {
            return comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier,
                                                 for: indexPath) as! MediaCommentsViewCell
        
        if let initialComment = initialComment,
            let usernameOfOwner = usernameOfOwner,
            let profilePictureOfOwner = profilePictureOfOwner {
            
            if indexPath.row == 0 {
                setProfilePicture(for: cell, url: profilePictureOfOwner)
                cell.label.attributedText = attributedString(username: usernameOfOwner, commentText: initialComment)
            } else {
                let comment = comments[indexPath.row-1]
                setProfilePicture(for: cell, url: comment.profilePicture)
                cell.label.attributedText = attributedString(comment: comment)
            }
            
        } else {
            let comment = comments[indexPath.row]
            setProfilePicture(for: cell, url: comment.profilePicture)
            cell.label.attributedText = attributedString(comment: comment)
        }
        
        return cell
    }
    
    func setProfilePicture(for cell: MediaCommentsViewCell, url: URL) {
        
        cell.profilePictureURL = url
        SDWebImageManager.shared().downloadImage(with: url, options: [], progress: nil)
        { (image, error, cacheType, finished, url) in
            if let image = image, cell.profilePictureURL == url {
                cell.profilePicture.image = image
            }
        }
    }
    
    func attributedString(comment: MediaItemComment) -> NSAttributedString {
        return attributedString(username: comment.userName, commentText: comment.text)
    }
    
    func attributedString(username: String, commentText: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: "\(username) \(commentText)")
        let usernameLength = username.characters.count
        attributedString.addAttribute(NSFontAttributeName,
                                      value: UIFont.boldSystemFont(ofSize: 17),
                                      range: NSRange(location: 0, length: usernameLength))
        return attributedString
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

class MediaCommentsViewCell: UITableViewCell {
    
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var label: UILabel!
    
    var profilePictureURL: URL?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profilePicture.layer.cornerRadius = profilePicture.width * 0.5
    }
    
}


