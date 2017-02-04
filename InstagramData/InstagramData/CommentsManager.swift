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
        }
    }
    
    private func initializeNewCommentsList() {
        let comments: [MediaItemComment]
        if hasCaption {
            let captionComment = MediaItemComment(captionItemId,
                                                  text: mediaItem.caption!,
                                                  userId: mediaItem.owner.id,
                                                  userName: mediaItem.owner.username,
                                                  profilePicture: mediaItem.owner.profilePictureURL)
            comments = mediaItem.comments + [captionComment]
        } else {
            comments = mediaItem.comments
        }
        commentsList.addNewComments(comments, with: mediaItem.commentsStartCursor)
    }
    
    public func comment(at index: Int) -> MediaItemComment? {
        
        guard index < numberOfAvailableComments else {
            return nil
        }
        
        guard !hasCaption || index > 0 else {
            return captionComment()
        }
        
        let commentId = commentsList.itemIDsBeforeFirstGap[index]
        return comment(with: commentId)
    }
    
    private func captionComment() -> MediaItemComment? {
        return comment(with: captionItemId)
    }
    
    private func comment(with id: String) -> MediaItemComment? {
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
