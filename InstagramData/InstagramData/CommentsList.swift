//
//  CommentsList.swift
//  InstagramData
//
//  Created by Ben Davis on 04/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import Foundation

class CommentsList: GappedList {
    
    private let commentDataStore: CommentsDataStore
    
    init(name: String, commentDataStore: CommentsDataStore, listDataStore: GappedListDataStore) {
        self.commentDataStore = commentDataStore
        super.init(name: name, listDataStore: listDataStore)
    }
    
    func comment(with id: String, completion: @escaping (MediaItemComment?)->Void) {
        commentDataStore.loadComment(with: id, completion: completion)
    }
    
    func appendMoreComments(_ newComments: [MediaItemComment], from startCursor: String, to newEndCursor: String?) {
        if indexOfGap(withCursor: startCursor) != nil {
            commentDataStore.archiveComments(newComments)
        }
        
        let newCommentsIds: [String] = newComments.map({ $0.id })
        super.appendMoreItems(newCommentsIds, from: startCursor, to: newEndCursor)
    }
    
    func addNewComments(_ newComments: [MediaItemComment], with newEndCursor: String?) {
        commentDataStore.archiveComments(newComments)
        let newCommentsIds: [String] = newComments.map({ $0.id })
        super.addNewItems(newCommentsIds, with: newEndCursor)
    }
}
