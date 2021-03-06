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
    
    public let hasCaption: Bool
    
    public func captionComment() -> MediaItemComment? {
        if let caption = mediaItem.caption {
            return MediaItemComment(captionItemId,
                                    text: caption,
                                    user: mediaItem.owner,
                                    replies: [])
        }
        return nil
    }
    
    public var numberOfAvailableComments: Int {
        return commentsList.itemIDsBeforeFirstGap.count
    }
    
    public var canLoadMoreComments: Bool {
        let hasNoComments = numberOfAvailableComments == 0
        return numberOfAvailableComments < mediaItem.commentsCount && (hasNoComments || endCursor != nil)
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
    }
    
    public func comment(at index: Int) -> MediaItemComment? {
        
        guard index < numberOfAvailableComments else {
            return nil
        }
        
        let commentId = commentsList.itemIDsBeforeFirstGap[index]
        
        return comment(with: commentId)
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
    
    public func fetchComments(_ completion: (()->())?, failure: (()->())? = nil) {
        commentsWebStore.getComments(for: mediaItem.code,
                                     from: "{}",
                                     completion: { (newComments, endCursor) in
            self.commentsList.addNewComments(newComments, with: endCursor)
            completion?()
        }, failure: failure)
    }
    
    public func fetchMoreComments(_ completion: (()->())?, failure: (()->())? = nil) {
        
        guard numberOfAvailableComments > 0 else {
            return fetchComments(completion, failure: failure)
        }
        
        guard let currentEndCursor = self.endCursor else {
            return
        }
        
        commentsWebStore.getComments(for: mediaItem.code,
                                     from: currentEndCursor,
                                     completion: { (newComments, endCursor) in
            self.commentsList.appendMoreComments(newComments, from: currentEndCursor, to: endCursor)
            completion?()
        }, failure: failure)
    }
    
}
