//
//  MediaGridView.swift
//  Instagram
//
//  Created by Ben Davis on 29/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import UIKit
import InstagramData

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
    func mediaItem(at index: Int) -> MediaItem
}

protocol MediaGridViewDelegate: class {
    func mediaGridView(_ sender: MediaGridView, userTappedCellForItem mediaItem: MediaItem, imageView: UIImageView)
}

class MediaGridView: UICollectionView {

    static let reuseIdentifier = "cell"
    static let minItemSize: CGFloat = 300
    
    var resizesWithNavigationBar: Bool = false
    var navigationBarHeightForSizeCalculations: CGFloat = 64
    
    weak var mediaGridViewDelegate: MediaGridViewDelegate?
    
    var mediaGridViewDataSource: MediaGridViewDataSource? {
        return dataSource as? MediaGridViewDataSource
    }

    fileprivate var flowLayout: UICollectionViewFlowLayout {
        return self.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: MediaGridView.minItemSize, height: MediaGridView.minItemSize)
        super.init(frame: .zero, collectionViewLayout: layout)
        self.register(UINib(nibName: "MediaGridViewCell", bundle: nil), forCellWithReuseIdentifier: MediaGridView.reuseIdentifier)
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        didSet {
            if frame != oldValue {
                preserveCurrentScrollPosition()
                setScrollDirection()
            }
        }
    }
    
    override var contentSize: CGSize {
        didSet {
            let oldShortestEdge = min(oldValue.width, oldValue.height)
            let newShortestEdge = min(contentSize.width, contentSize.height)
            if oldShortestEdge != newShortestEdge {
                updateImageSize()
            }
        }
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
    
    func preserveCurrentScrollPosition() {
        let oldOffset = currentOffset()
        let navigationBarHeight = resizesWithNavigationBar ? 0 : navigationBarHeightForSizeCalculations
        DispatchQueue.main.async {
            if self.flowLayout.scrollDirection == .horizontal {
                self.contentOffset = CGPoint(x: oldOffset, y: self.contentOffset.y)
            } else {
                self.contentOffset = CGPoint(x: self.contentOffset.x, y: oldOffset - navigationBarHeight)
            }
        }
    }
    
    private func currentOffset() -> CGFloat {
        let navigationBarHeight = resizesWithNavigationBar ? 0 : navigationBarHeightForSizeCalculations
        if flowLayout.scrollDirection == .horizontal {
            return max(contentOffset.x - navigationBarHeight*2, 0)
        } else {
            return max(contentOffset.y - navigationBarHeight, 0)
        }
    }
}

extension MediaGridView {
    
    func updateImageSize() {
        let newItemSize = calculateBestItemSize()
        flowLayout.itemSize = CGSize(width: newItemSize, height: newItemSize)
        performBatchUpdates({}) // Animates the change in size
    }
    
    func calculateBestItemSize() -> CGFloat {
        let navigationBarHeight = resizesWithNavigationBar ? 0 : navigationBarHeightForSizeCalculations
        let shortestEdge: CGFloat = min(contentSize.width - navigationBarHeight, contentSize.height)
        let numberOfItems: CGFloat = (shortestEdge / MediaGridView.minItemSize).rounded(.down)
        if numberOfItems == 0 {
            return MediaGridView.minItemSize
        }
        let spacing = self.flowLayout.minimumInteritemSpacing*(numberOfItems-1)
        return (shortestEdge-spacing) / numberOfItems
    }
}

extension MediaGridView: UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.height {
            mediaGridViewDataSource?.mediaGridViewNeedsMoreMedia(self)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        mediaGridViewDataSource?.mediaGridViewNeedsUpdateVisibleCells(self)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mediaItem = mediaGridViewDataSource!.mediaItem(at: indexPath.item)
        let cell = collectionView.cellForItem(at: indexPath) as! MediaGridViewCell
        mediaGridViewDelegate?.mediaGridView(self, userTappedCellForItem: mediaItem, imageView:cell.imageView)
    }
}
