//
//  MediaGridView.swift
//  Instagram
//
//  Created by Ben Davis on 29/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import UIKit
import InstagramData
import SwiftToolbox

struct MediaGridViewItem: Equatable {
    let id: String
    
    let url: URL
    let profilePicture: URL
    let username: String
    let code: String
    let viewerHasLiked: Bool
    
    public static func ==(lhs: MediaGridViewItem, rhs: MediaGridViewItem) -> Bool {
        return lhs.id == rhs.id
    }
}

protocol MediaGridViewDataSource: UICollectionViewDataSource {
    func mediaGridViewNeedsMoreMedia(_ sender: MediaGridView)
    func mediaGridViewNeedsUpdateVisibleCells(_ sender: MediaGridView)
    func mediaGridView(_ sender: MediaGridView, mediaItemAt index: Int) -> MediaItem
    func mediaGridView(_ sender: MediaGridView, indexPathOfItemWith id: String) -> IndexPath?
}

protocol MediaGridViewDelegate: class {
    func mediaGridView(_ sender: MediaGridView, userTappedCellForItem mediaItem: MediaItem, imageView: UIImageView)
    func mediaGridView(_ sender: MediaGridView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize
}

class MediaGridView: UICollectionView {

    static let reuseIdentifier = "cell"

    static let preferreredMinimumItemSize: CGFloat = 300
    var minItemSize: CGFloat {
        return min(width, min(height, MediaGridView.preferreredMinimumItemSize))
    }
    
    weak var mediaGridViewDelegate: MediaGridViewDelegate?
    weak var mediaGridViewDataSource: MediaGridViewDataSource?

    var flowLayout: UICollectionViewFlowLayout {
        return self.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: MediaGridView.preferreredMinimumItemSize,
                                 height: MediaGridView.preferreredMinimumItemSize)
        layout.minimumInteritemSpacing = 2.0
        layout.minimumLineSpacing = 2.0
        super.init(frame: .zero, collectionViewLayout: layout)
        
        self.register(UINib(nibName: "MediaGridViewCell", bundle: nil),
                      forCellWithReuseIdentifier: MediaGridView.reuseIdentifier)
        
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func imageViewForMediaItem(_ mediaItem: MediaItem) -> UIImageView? {
        if let indexPath = mediaGridViewDataSource?.mediaGridView(self, indexPathOfItemWith: mediaItem.id) {
            let cell = cellForItem(at: indexPath) as? MediaGridViewCell
            return cell?.imageView
        }
        return nil
    }
}

extension MediaGridView {
    
    func setScrollDirection() {
        if width > height {
            flowLayout.scrollDirection = .horizontal
        } else {
            flowLayout.scrollDirection = .vertical
        }
    }
    
    func resetScrollPosition(to indexPath: IndexPath?, animated: Bool = false) {
        guard let indexPath = indexPath,
            numberOfSections > indexPath.section,
            numberOfItems(inSection: indexPath.section) > indexPath.item else { return }
        
        if flowLayout.scrollDirection == .horizontal {
            scrollToItem(at: indexPath, at: .left, animated: animated)
        } else {
            scrollToItem(at: indexPath, at: .top, animated: animated)
        }
    }
    
    func firstVisibleIndexPath() -> IndexPath? {
        var firstIndexPath = indexPathsForVisibleItems.first
        for indexPath in indexPathsForVisibleItems {
            if indexPath.section < firstIndexPath!.section ||
                indexPath.row < firstIndexPath!.row {
                firstIndexPath = indexPath
            }
        }
        
        // First item may be under nav bar
        if let firstIndexPath = firstIndexPath, flowLayout.scrollDirection == .vertical {
            let position = cellForItem(at: firstIndexPath)!.originY - contentOffset.y
            let itemSize = flowLayout.itemSize.height
            if position + itemSize < contentInset.top {
                let numberOfItemsInRow = Int((width / itemSize).rounded(.down))
                let newItemIndex = firstIndexPath.item + numberOfItemsInRow
                if newItemIndex < numberOfItems(inSection: firstIndexPath.section) {
                    return IndexPath(item: newItemIndex, section: firstIndexPath.section)
                } else if firstIndexPath.section + 1 < numberOfSections {
                    return IndexPath(item: 0, section: firstIndexPath.section + 1)
                }
            }
        }
        
        return firstIndexPath
    }

}

extension MediaGridView {
    
    func updateImageSize() {
        let newItemSize = calculateBestItemSize()
        flowLayout.itemSize = CGSize(width: newItemSize, height: newItemSize)
        flowLayout.invalidateLayout()
    }
    
    func calculateBestItemSize() -> CGFloat {
        let shortestEdge: CGFloat = min(contentSize.width, contentSize.height - contentInset.top)
        let numberOfItems: CGFloat = (shortestEdge / minItemSize).rounded(.down)
        if numberOfItems == 0 {
            return minItemSize
        }
        let spacing = self.flowLayout.minimumInteritemSpacing*(numberOfItems-1)
        return (shortestEdge-spacing) / numberOfItems
    }
}

extension MediaGridView: UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isTouchingEnd(of: scrollView) {
            mediaGridViewDataSource?.mediaGridViewNeedsMoreMedia(self)
        }
    }
    
    private func isTouchingEnd(of scrollView: UIScrollView) -> Bool {
        
        guard scrollView.frame.size != scrollView.contentSize else {
            return false
        }
        
        if flowLayout.scrollDirection == .horizontal {
            if scrollView.contentOffset.x == scrollView.contentSize.width - scrollView.width {
                return true
            }
        } else {
            if scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.height {
                return true
            }
        }
        
        return false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        mediaGridViewDataSource?.mediaGridViewNeedsUpdateVisibleCells(self)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mediaItem = mediaGridViewDataSource!.mediaGridView(self, mediaItemAt: indexPath.item)
        if let cell = collectionView.cellForItem(at: indexPath) as? MediaGridViewCell {
            mediaGridViewDelegate?.mediaGridView(self, userTappedCellForItem: mediaItem, imageView:cell.imageView)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let mediaGridViewDelegate = mediaGridViewDelegate {
            return mediaGridViewDelegate.mediaGridView(self, layout: collectionViewLayout, sizeForItemAt: indexPath)
        }
        
        return flowLayout.itemSize
    }
    
}
