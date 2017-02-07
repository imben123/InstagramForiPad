//
//  CommentsManager.swift
//  InstagramData
//
//  Created by Ben Davis on 04/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import Foundation

public class CommentsManager {
    
    public let mediaItem: MediaItem
    private let commentsWebStore: CommentsWebStore
    private let commentsList: CommentsList
    private let captionItemId: String
    private let hasCaption: Bool
    
    public var numberOfAvailableComments: Int {
        if hasCaption {
            return commentsList.itemIDsBeforeFirstGap.count + 1
        }
        return commentsList.itemIDsBeforeFirstGap.count
    }
    
    private var endCursor: String? {
        return commentsList.firstGapCursor
    }

    init(mediaItem: MediaItem, communicator: APICommunicator) {
        self.mediaItem = mediaItem
        self.commentsWebStore = CommentsWebStore(communicator: communicator)
        self.captionItemId = "\(mediaItem.id).caption"
        self.hasCaption = (mediaItem.caption != nil)
        self.commentsList = CommentsList(name: "GappedCommentsList.\(mediaItem.id)",
                                         commentDataStore: CommentsDataStore(),
                                         listDataStore: GappedListDataStore())
        
        if commentsList.itemCount == 0 {
            initializeNewCommentsList()
        } else {
            checkCommentsListIsUpToDate()
        }
    }
    
    private func initializeNewCommentsList() {
        let comments = mediaItem.comments
        commentsList.addNewComments(comments, with: mediaItem.commentsStartCursor)
    }
    
    private func checkCommentsListIsUpToDate() {
        let comments = mediaItem.comments
        if comments.last?.id != commentsList.itemIDsBeforeFirstGap.first {
            commentsList.addNewComments(comments, with: mediaItem.commentsStartCursor)
        }
    }
    
    public func comment(at index: Int) -> MediaItemComment? {
        
        guard index < numberOfAvailableComments else {
            return nil
        }
        
        if hasCaption && index == 0 {
            return captionComment()
        }
        
        let commentId = commentsList.itemIDsBeforeFirstGap[index-1]
        return comment(with: commentId)
    }
    
    private func captionComment() -> MediaItemComment? {
        if let caption = mediaItem.caption {
            return MediaItemComment(captionItemId,
                                    text: caption,
                                    userId: mediaItem.owner.id,
                                    userName: mediaItem.owner.username,
                                    profilePicture: mediaItem.owner.profilePictureURL)
        }
        return nil
    }
    
    private func comment(with id: String) -> MediaItemComment? {
        
        guard id != captionItemId else {
            return captionComment()
        }
        
        var result: MediaItemComment?
        
        let semaphore = DispatchSemaphore(value: 0)
        commentsList.comment(with: id) { comment in
            result = comment
            semaphore.signal()
        }
        semaphore.wait()
        
        return result
    }
    
    public func fetchMoreComments(_ completion: (()->())?, failure: (()->())? = nil) {
        guard let currentEndCursor = self.endCursor else {
            return
        }
        
        commentsWebStore.getComments(for: mediaItem.code,
                                     from: currentEndCursor,
                                     completion: { (newComments, newEndCursor) in
            self.commentsList.appendMoreComments(newComments, from: currentEndCursor, to: newEndCursor)
            completion?()
        }, failure: failure)
    }
    
}
