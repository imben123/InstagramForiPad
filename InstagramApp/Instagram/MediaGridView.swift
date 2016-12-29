//
//  MediaGridView.swift
//  Instagram
//
//  Created by Ben Davis on 29/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import UIKit

struct MediaGridViewItem {
    let url: URL
}

protocol MediaGridViewDelegate: class {
    func mediaGridView(_ sender: MediaGridView, imageForItem item: MediaGridViewItem) -> UIImage?
}

class MediaGridView: UICollectionView {

    fileprivate static let reuseIdentifier = "cell"

    weak var mediaDelegate: MediaGridViewDelegate?
    
    fileprivate var currentItems: [MediaGridViewItem] = []
    var items: [MediaGridViewItem] {
        get {
            return currentItems
        }
        set {
            currentItems = newValue
            self.reloadData()
        }
    }
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 150)
        super.init(frame: .zero, collectionViewLayout: layout)
        self.register(MediaGridViewCell.self, forCellWithReuseIdentifier: MediaGridView.reuseIdentifier)
        self.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MediaGridView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.currentItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MediaGridViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaGridView.reuseIdentifier,
                                                                         for: indexPath) as! MediaGridViewCell
        cell.backgroundColor = .red
        if let mediaDelegate = mediaDelegate {
            cell.imageView.image = mediaDelegate.mediaGridView(self, imageForItem: currentItems[indexPath.row])
        }
        return cell
    }
    
}
