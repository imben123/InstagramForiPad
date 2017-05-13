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

    var onProfilePictureTapped: ( (_ user: User) -> (()->Void)? )?
    
    fileprivate var commentsManager: CommentsManager!
    fileprivate var mediaItem: MediaItem!
    
    fileprivate var numberOfAvailableComments: Int {
        return commentsManager.numberOfAvailableComments
    }
    
    private var shouldShowLoadMoreComments: Bool {
        return numberOfAvailableComments < mediaItem.commentsCount
    }
    
    func setComments(_ mediaItem: MediaItem) {
        self.mediaItem = mediaItem
        self.commentsManager = InstagramData.shared.createCommentsManager(for: mediaItem)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var result = numberOfAvailableComments
        if shouldShowLoadMoreComments {
            result += 1
        }
        if commentsManager.hasCaption {
            result += 1
        }
        
        return result
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPathIsLoadMoreCommentsRow(indexPath) {
            
            return MediaCommentsViewLoadMoreCommentsCell(style: .default, reuseIdentifier: "Load more cell")
            
        } else {
    
            let cell = tableView.dequeueReusableCell(withIdentifier: MediaCommentsViewDataSource.cellReuseIdentifier,
                                                     for: indexPath) as! MediaCommentsViewCell
            
            let comment: MediaItemComment
            if indexPathIsCaptionRow(indexPath) {
                cell.separatorInset = .zero
                comment = commentsManager.captionComment()!
            } else {
                let commentIndex = self.commentIndex(from: indexPath)
                comment = commentsManager.comment(at: commentIndex)!
            }
            
            setProfilePicture(for: cell, url: comment.user.profilePictureURL)
            cell.label.attributedText = attributedString(comment: comment)
            cell.onProfilePictureTapped = self.onProfilePictureTapped?(comment.user)
            
            return cell
        }
    }
    
    func indexPathIsLoadMoreCommentsRow(_ indexPath: IndexPath) -> Bool {
        guard shouldShowLoadMoreComments else {
            return false
        }
        
        if commentsManager.hasCaption {
            return indexPath.row == 1
        } else {
            return indexPath.row == 0
        }
    }
    
    func indexPathIsCaptionRow(_ indexPath: IndexPath) -> Bool {
        guard commentsManager.hasCaption else {
            return false
        }
        return indexPath.row == 0
    }
    
    func commentIndex(from indexPath: IndexPath) -> Int {
        var row = indexPath.row
        
        if shouldShowLoadMoreComments {
            row -= 1
        }
        
        if commentsManager.hasCaption {
            row -= 1
        }
        
        return (numberOfAvailableComments - 1) - row
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
        return attributedString(username: comment.user.username, commentText: comment.text)
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
        if indexPathIsLoadMoreCommentsRow(indexPath) {
            commentsManager.fetchMoreComments({ 
                tableView.reloadData()
            })
        }
    }
    
}
