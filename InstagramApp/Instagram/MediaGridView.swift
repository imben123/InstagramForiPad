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
}

class MediaGridView: UICollectionView {

    static let reuseIdentifier = "cell"
    static let minItemSize: CGFloat = 300
    
    var resizesWithNavigationBar: Bool = false
    var navigationBarHeightForSizeCalculations: CGFloat = 64
    
    fileprivate var mediaGridViewDataSource: MediaGridViewDataSource? {
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
            }
        }
    }
    
    override var contentSize: CGSize {
        didSet {
            if contentSize != oldValue {
                updateImageSize()
            }
        }
    }
}

extension MediaGridView {
    
    func preserveCurrentScrollPosition() {
        let indexPath = firstVisibleIndexPath()
        if width > height {
            flowLayout.scrollDirection = .horizontal
            if let indexPath = indexPath {
                self.scrollToItem(at: indexPath, at: .left, animated: false)
            }
        } else {
            flowLayout.scrollDirection = .vertical
            if let indexPath = indexPath {
                self.scrollToItem(at: indexPath, at: .top, animated: false)
            }
        }
    }
    
    func firstVisibleIndexPath() -> IndexPath? {
        var firstIndexPath = indexPathsForVisibleItems.first
        for indexPath in indexPathsForVisibleItems {
            if indexPath.row < firstIndexPath!.row {
                firstIndexPath = indexPath
            }
        }
        return firstIndexPath
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
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if contentSize.width < contentSize.height {
            let itemSize = flowLayout.itemSize.width
            let spacing = flowLayout.minimumInteritemSpacing
            let width = collectionView.width
            let numberOfItems = (contentSize.width / (itemSize + spacing)).rounded(.down)
            let inset = (width - (numberOfItems * itemSize)) / (numberOfItems + 1)
            return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        } else {
            return .zero
        }
    }
}
