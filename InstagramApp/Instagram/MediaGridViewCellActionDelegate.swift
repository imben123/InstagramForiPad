//
//  MediaGridViewCellActionDelegate.swift
//  Instagram
//
//  Created by Ben Davis on 16/04/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import InstagramData

extension MediaFeedGridViewDataSource: MediaGridViewCellUserActionDelegate {
    
    func mediaGridViewCellLikePressed(_ mediaGridViewCell: MediaGridViewCell) {
        let mediaId = mediaGridViewCell.currentItem!.id
        InstagramData.shared.likeReqestsManager.likePost(with: mediaId)
        updateMediaItemInMemCache(for: mediaId, liked: true)
    }
    
    func mediaGridViewCellUnlikePressed(_ mediaGridViewCell: MediaGridViewCell) {
        let mediaId = mediaGridViewCell.currentItem!.id
        InstagramData.shared.likeReqestsManager.unlikePost(with: mediaGridViewCell.currentItem!.id)
        updateMediaItemInMemCache(for: mediaId, liked: false)
    }
    
    func updateMediaItemInMemCache(for mediaId: String, liked: Bool) {
        mediaFeed.mediaItem(for: mediaId) { (mediaItem) in
            if let mediaItem = mediaItem {
                var mediaItem = mediaItem
                mediaItem.viewerHasLiked = liked
                self.mediaFeed.updateMediaItemInMemCache(with: mediaItem)
            }
        }
    }
    
    func mediaGridViewCellOwnerPressed(_ mediaGridViewCell: MediaGridViewCell) {
        let mediaId = mediaGridViewCell.currentItem!.id
        if let index = indexOfItem(with: mediaId) {
            let mediaItem = self.mediaItem(at: index)
            userActionDelegate?.mediaGridViewDataSource(self, userPressOwnerOfMediaItem: mediaItem)
        }
    }
}
