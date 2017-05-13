//
//  MediaGridViewDataSource.swift
//  Instagram
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import UIKit
import InstagramData
import SDWebImage

protocol MediaFeedGridViewDataSourceUserActionDelegate: class {
    func mediaGridViewDataSource(_ sender: MediaFeedGridViewDataSource, userPressOwnerOfMediaItem mediaItem: MediaItem)
}

protocol MediaFeedGridViewDataSourceObserver: class {
    func mediaGridViewDataSource(_ sender: MediaFeedGridViewDataSource, mediaFeedUpdated itemCount: Int)
}

class MediaFeedGridViewDataSource: NSObject {
    
    let mediaGridView: MediaGridView
    let mediaFeed: MediaFeed
    
    fileprivate var mediaIDs: [String]
    
    var section: Int = 0

    weak var userActionDelegate: MediaFeedGridViewDataSourceUserActionDelegate?
    weak var observer: MediaFeedGridViewDataSourceObserver?
    
    // TODO: move this logic to managers
    var fetchingMoreMedia = false
    
    init(mediaFeed: MediaFeed, mediaGridView: MediaGridView) {
        self.mediaGridView = mediaGridView
        self.mediaFeed = mediaFeed
        self.mediaIDs = mediaFeed.mediaIDs
        super.init()
        mediaGridView.dataSource = self
    }
    
    func reloadGridViewContent() {
        mediaIDs = mediaFeed.mediaIDs
        mediaGridView.reloadData()
    }
    
    func updateLatestMedia() {
        fetchLatestMedia()
        refreshMostRecentPosts()
    }
    
    private func fetchLatestMedia() {
        
        mediaFeed.fetchNewestMedia({ [weak self] in
            
            guard let strongself = self,
                let newMediaCount = self?.mediaFeed.mediaCount else {
                    return
            }
            
            strongself.reloadGridViewContent()
            strongself.observer?.mediaGridViewDataSource(strongself, mediaFeedUpdated: newMediaCount)
            
        })
    }
    
    private func refreshMostRecentPosts() {
        
        let numberOfPosts = mediaIDs.count
        
        // Update 20 most recent
        for index in 0..<min(20, numberOfPosts) {
            let mediaItem = self.mediaItem(at: index)
            InstagramData.shared.mediaManager.updateMediaItem(mediaItem)
        }
    }
    
    func loadMoreMedia() {
        
        guard fetchingMoreMedia == false else {
            return
        }
        
        fetchingMoreMedia = true
        mediaFeed.fetchMoreMedia({ [weak self] in
            self?.reloadGridViewContent()
            self?.fetchingMoreMedia = false
            }, failure: { [weak self] in
                self?.fetchingMoreMedia = false
        })
    }
    
    func reloadCell(for item: MediaGridViewItem) {
        guard let index = index(of: item),
            mediaGridView.numberOfSections > section,
            mediaGridView.numberOfItems(inSection: section) > index else {
            return
        }
        let indexPath = IndexPath(item: index, section: section)
        mediaGridView.reloadItems(at: [indexPath])
    }
}

extension MediaFeedGridViewDataSource: MediaGridViewDataSource {
    
    func mediaGridViewNeedsMoreMedia(_ sender: MediaGridView) {
        loadMoreMedia()
    }
    
    func mediaGridViewNeedsUpdateVisibleCells(_ sender: MediaGridView) {
        
        let visibleIndexPaths = mediaGridView.indexPathsForVisibleItems
        
        let urls = visibleIndexPaths.map { indexPath -> URL in
            mediaItem(at: indexPath.item).display
        }
        SDWebImagePrefetcher.shared().prefetchURLs(urls)
        
        // Make cell image high priority if the image doesn't already exist
        for indexPath in visibleIndexPaths {
            if let cell = sender.cellForItem(at: indexPath) as? MediaGridViewCell, cell.imageView.image == nil {
                let configurator = MediaGridViewCellConfigurator(mediaItem: cell.currentItem!,
                                                                 reloadCellForItem: reloadCell(for:))
                configurator.setImage(for: cell, highPriority: true)
            }
        }
    }
    
    func mediaGridView(_ sender: MediaGridView, mediaItemAt index: Int) -> MediaItem {
        return mediaItem(at: index)
    }
    
    func mediaGridView(_ sender: MediaGridView, indexPathOfItemWith id: String) -> IndexPath? {
        if let index = indexOfItem(with: id) {
            return IndexPath(item: index, section: section)
        }
        return nil
    }
}

extension MediaFeedGridViewDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaIDs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: MediaGridViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaGridView.reuseIdentifier,
                                                                         for: indexPath) as! MediaGridViewCell
        
        configureCell(cell, atIndexPath: indexPath)
        cell.userActionDelegate = self
        return cell
    }
    
    private func configureCell(_ cell: MediaGridViewCell, atIndexPath indexPath: IndexPath) {
        let mediaItem = item(at: indexPath.row)
        let configurator = MediaGridViewCellConfigurator(mediaItem: mediaItem,
                                                         reloadCellForItem: reloadCell(for:))
        configurator.configureCell(cell)
    }
    
}

// Helpers
extension MediaFeedGridViewDataSource {
    
    func mediaItem(at index: Int) -> MediaItem {
        let mediaID = mediaIDs[index]
        
        var mediaItem: MediaItem!
        let sema = DispatchSemaphore(value: 0)
        mediaFeed.mediaItem(for: mediaID) { (result) in
            mediaItem = result
            sema.signal()
        }
        sema.wait()
        return mediaItem
    }
    
    func index(of item: MediaGridViewItem) -> Int? {
        return indexOfItem(with: item.id)
    }
    
    func indexOfItem(with id: String) -> Int? {
        return mediaIDs.index(of: id)
    }
    
    func item(at index: Int) -> MediaGridViewItem {
        let mediaItem = self.mediaItem(at: index)
        return MediaGridViewItem(id: mediaItem.id,
                                 url: mediaItem.thumbnail,
                                 profilePicture: mediaItem.owner.profilePictureURL,
                                 username: mediaItem.owner.username,
                                 code: mediaItem.code,
                                 viewerHasLiked: mediaItem.viewerHasLiked)
    }
    
    func items(for indexPaths: [IndexPath]) -> [MediaGridViewItem] {
        var result: [MediaGridViewItem] = []
        for indexPath in indexPaths {
            result.append(item(at: indexPath.row))
        }
        return result
    }
}
