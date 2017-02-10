//
//  MediaCommentsViewDataSource.swift
//  Instagram
//
//  Created by Ben Davis on 04/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import UIKit
import SDWebImage
import InstagramData

class MediaCommentsViewDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

    static let cellReuseIdentifier: String = "MediaCommentsViewCell"

    fileprivate var commentsManager: CommentsManager!
    fileprivate var mediaItem: MediaItem!
    
    fileprivate var numberOfAvailableComments: Int {
        return commentsManager.numberOfAvailableComments
    }
    
    func setComments(_ mediaItem: MediaItem) {
        self.mediaItem = mediaItem
        self.commentsManager = InstagramData.shared.createCommentsManager(for: mediaItem)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if numberOfAvailableComments < mediaItem.commentsCount {
            return numberOfAvailableComments + 1
        } else {
            return numberOfAvailableComments
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < numberOfAvailableComments {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: MediaCommentsViewDataSource.cellReuseIdentifier,
                                                     for: indexPath) as! MediaCommentsViewCell
            
            let comment = commentsManager.comment(at: indexPath.row)!
            setProfilePicture(for: cell, url: comment.profilePicture)
            cell.label.attributedText = attributedString(comment: comment)
            
            if indexPath.row == 0 && mediaItem.caption != nil {
                cell.separatorInset = .zero
            }
            
            return cell
            
        } else {
            return MediaCommentsViewLoadMoreCommentsCell(style: .default, reuseIdentifier: "Load more cell")
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.selectRow(at: nil, animated: false, scrollPosition: .none)
        if indexPath.row == numberOfAvailableComments {
            commentsManager.fetchMoreComments({ 
                tableView.reloadData()
            })
        }
    }
    
}
