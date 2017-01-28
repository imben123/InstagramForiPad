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
    let viewerHasLiked: Bool
    
    public static func ==(lhs: MediaGridViewItem, rhs: MediaGridViewItem) -> Bool {
        return lhs.id == rhs.id
    }
}

class MediaGridView: UICollectionView {

    static let reuseIdentifier = "cell"
    static let minItemSize: CGFloat = 300
    
    var resizesWithNavigationBar: Bool = true
    var navigationBarHeightForSizeCalculations: CGFloat = 64

    fileprivate var flowLayout: UICollectionViewFlowLayout {
        return self.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: MediaGridView.minItemSize, height: MediaGridView.minItemSize)
        super.init(frame: .zero, collectionViewLayout: layout)
        self.register(UINib(nibName: "MediaGridViewCell", bundle: nil), forCellWithReuseIdentifier: MediaGridView.reuseIdentifier)
        self.dataSource = self
        InstagramData.shared.feedManager.prefetchingDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadCell(for item: MediaGridViewItem) {
        guard let index = index(of: item) else {
            return
        }
        let indexPath = IndexPath(item: index, section: 0)
        self.reloadItems(at: [indexPath])
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = newValue
            preserveCurrentScrollPosition()
        }
    }
    
    override var contentSize: CGSize {
        get {
            return super.contentSize
        }
        set {
            super.contentSize = newValue
            updateImageSize()
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
    }
    
    func calculateBestItemSize() -> CGFloat {
        let navigationBarHeight = resizesWithNavigationBar ? navigationBarHeightForSizeCalculations : 0
        let shortestEdge: CGFloat = min(contentSize.width - navigationBarHeight, contentSize.height)
        let numberOfItems: CGFloat = (shortestEdge / MediaGridView.minItemSize).rounded(.down)
        if numberOfItems == 0 {
            return MediaGridView.minItemSize
        }
        let spacing = self.flowLayout.minimumInteritemSpacing*(numberOfItems-1)
        return (shortestEdge-spacing) / numberOfItems
    }
}
