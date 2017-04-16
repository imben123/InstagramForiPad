//
//  MediaGridViewCellConfigurator.swift
//  Instagram
//
//  Created by Ben Davis on 16/04/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import SDWebImage

class MediaGridViewCellConfigurator {
    
    let mediaItem: MediaGridViewItem
    let reloadCellForItem: (MediaGridViewItem)->Void
    
    init(mediaItem: MediaGridViewItem, reloadCellForItem: @escaping (MediaGridViewItem)->Void) {
        self.mediaItem = mediaItem
        self.reloadCellForItem = reloadCellForItem
    }
    
    func configureCell(_ cell: MediaGridViewCell) {
        cell.currentItem = mediaItem
        cell.liked = cell.currentItem!.viewerHasLiked
        cell.username.text = cell.currentItem?.username
        setImage(for: cell)
        setProfilePictureImage(for: cell)
    }
    
    // Used the hold the download operation and cancel it if the cell is reused
    class MediaGridViewCellOperationDelegate: MediaGridViewCellDelegate {
        var imageDownloadOperation: SDWebImageOperation?
        var profilePictureDownloadOperation: SDWebImageOperation?
        
        func mediaGridViewCellWillPrepareForReuse(_ mediaGridViewCell: MediaGridViewCell) {
            
            // Performance is better when these are not cancelled.
            //
            // TODO: Come up with a better system that only cancels oldest image downloads
            //       when there are > 100(?) downloads in progress.
            //
            //       Perhaps an SDWebImage extension to auto-cancel from group of downloads
            //       when a given limit is exceeded.
            
            // imageDownloadOperation?.cancel()
            // profilePictureDownloadOperation?.cancel()
            
            imageDownloadOperation = nil
            profilePictureDownloadOperation = nil
            
        }
    }
    
    func setImage(for cell: MediaGridViewCell, highPriority: Bool = false) {
        let item = cell.currentItem!
        let image = SDImageCache.shared().imageFromMemoryCache(forKey: item.url.absoluteString)
        if let image = image {
            cell.imageView.image = image
            return
        }
        
        let cellDelegate = cellOperationsDelegate(for: cell)
        
        let options = highPriority ? SDWebImageOptions.highPriority : []
        cellDelegate.imageDownloadOperation = SDWebImageManager.shared().downloadImage(with: item.url,
                                                                                       options: options,
                                                                                       progress: nil)
        { [cellDelegate] (image, error, cacheType, finished, url) in
            if image != nil {
                self.reloadCellForItem(item)
            }
            cellDelegate.imageDownloadOperation = nil
        }
    }
    
    private func setProfilePictureImage(for cell: MediaGridViewCell) {
        let item = cell.currentItem!
        let image = SDImageCache.shared().imageFromMemoryCache(forKey: item.profilePicture.absoluteString)
        if let image = image {
            cell.profilePicture.image = image
            return
        }
        
        let cellDelegate = cellOperationsDelegate(for: cell)
        
        cellDelegate.profilePictureDownloadOperation = SDWebImageManager.shared().downloadImage(with: item.profilePicture,
                                                                                                options: [],
                                                                                                progress: nil)
        { [cellDelegate] (image, error, cacheType, finished, url) in
            if image != nil {
                self.reloadCellForItem(item)
            }
            cellDelegate.profilePictureDownloadOperation = nil
        }
    }
    
    private func cellOperationsDelegate(for cell: MediaGridViewCell) -> MediaGridViewCellOperationDelegate {
        if let result = cell.delegate as? MediaGridViewCellOperationDelegate {
            return result
        }
        let result = MediaGridViewCellOperationDelegate()
        cell.delegate = result
        return result
    }
}
