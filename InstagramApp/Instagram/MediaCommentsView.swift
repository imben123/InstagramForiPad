//
//  MediaCommentsView.swift
//  Instagram
//
//  Created by Ben Davis on 01/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import UIKit
import InstagramData

class MediaCommentsView: UIView {
    
    fileprivate var tableView: UITableView?
    private let dataSource: MediaCommentsViewDataSource
    
    fileprivate struct Constants {
        static let minCellHeight: CGFloat = 48
    }
    
    required init?(coder aDecoder: NSCoder) {
        dataSource = MediaCommentsViewDataSource()
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView?.frame = bounds
    }
    
    func setComments(_ mediaItem: MediaItem) {
        
        dataSource.setComments(mediaItem)
        createTableViewIfNeeded(mediaItem)
    }
    
    private func createTableViewIfNeeded(_ mediaItem: MediaItem) {
        if tableView == nil {
            
            tableView = UITableView(frame: .zero, style: .plain)
            let nib = UINib(nibName: "MediaCommentsViewCell", bundle: nil)
            tableView!.register(nib, forCellReuseIdentifier: MediaCommentsViewDataSource.cellReuseIdentifier)
            tableView!.delegate = dataSource
            tableView!.dataSource = dataSource
            tableView!.rowHeight = UITableViewAutomaticDimension
            tableView!.estimatedRowHeight = 140
            tableView!.tableFooterView = UIView()
            tableView!.backgroundColor = .clear
            addSubview(tableView!)
            
        } else {
            
            tableView!.reloadData()
        }
    }
}

class MediaCommentsViewCell: UITableViewCell {
    
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var label: UILabel!
    
    var profilePictureURL: URL?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profilePicture.layer.cornerRadius = profilePicture.width * 0.5
    }
    
}


