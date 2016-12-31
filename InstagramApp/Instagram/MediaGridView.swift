//
//  MediaGridView.swift
//  Instagram
//
//  Created by Ben Davis on 29/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import UIKit

struct MediaGridViewItem: Equatable {
    let url: URL
    
    public static func ==(lhs: MediaGridViewItem, rhs: MediaGridViewItem) -> Bool {
        return lhs.url == rhs.url
    }
}

class MediaGridView: UICollectionView {

    static let reuseIdentifier = "cell"

    fileprivate var flowLayout: UICollectionViewFlowLayout {
        return self.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 300, height: 300)
        super.init(frame: .zero, collectionViewLayout: layout)
        self.register(MediaGridViewCell.self, forCellWithReuseIdentifier: MediaGridView.reuseIdentifier)
        self.dataSource = self
        self.prefetchDataSource = self
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
