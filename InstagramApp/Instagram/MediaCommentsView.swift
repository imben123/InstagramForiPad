//
//  MediaCommentsView.swift
//  Instagram
//
//  Created by Ben Davis on 01/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import UIKit
import InstagramData

protocol MediaCommentsViewDelegate {
    
    func commentsView(_ sender: MediaCommentsView, tableViewNeedsDataSource tableView: UITableView)
}

class MediaCommentsView: UIVisualEffectView {
    
    var delegate: MediaCommentsViewDelegate?
    
    fileprivate var tableView: UITableView?
    
    fileprivate struct Constants {
        static let minCellHeight: CGFloat = 48
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView?.frame = bounds
    }
    
    func setComments(_ mediaItem: MediaItem) {
        
        if tableView == nil {
            createTableView()
        } else {
            tableView!.reloadData()
        }
    }
    
    private func createTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        let nib = UINib(nibName: "MediaCommentsViewCell", bundle: nil)
        tableView!.register(nib, forCellReuseIdentifier: MediaCommentsViewDataSource.cellReuseIdentifier)
        delegate?.commentsView(self, tableViewNeedsDataSource: tableView!)
        tableView!.rowHeight = UITableView.automaticDimension
        tableView!.estimatedRowHeight = 140
        tableView!.tableFooterView = UIView()
        tableView!.backgroundColor = .clear
        contentView.addSubview(tableView!)
    }
}

class MediaCommentsViewCell: UITableViewCell {
    
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var label: UILabel!
    
    var onProfilePictureTapped: (()->Void)?
    
    var profilePictureURL: URL?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profilePicture.layer.cornerRadius = profilePicture.width * 0.5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profilePicture.image = nil
        label.text = nil
        onProfilePictureTapped = nil
    }
    
    @IBAction func profilePictureTapped(_ sender: UIButton) {
        if let onProfilePictureTapped = onProfilePictureTapped {
            onProfilePictureTapped()
        }
    }
}

class MediaCommentsViewLoadMoreCommentsCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textLabel?.textAlignment = .center
        textLabel?.textColor = .blue
        backgroundColor = .clear
        textLabel?.font = .systemFont(ofSize: 14)
        textLabel?.text = "Load more comments"
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setHighlighted(_ setHighlighted: Bool, animated: Bool) {
        super.setHighlighted(setHighlighted, animated: animated)
        textLabel?.alpha = setHighlighted ? 0.4 : 1
    }
    
}


