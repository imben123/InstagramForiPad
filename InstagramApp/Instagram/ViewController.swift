//
//  ViewController.swift
//  Instagram
//
//  Created by Ben Davis on 29/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import UIKit
import InstagramData
import SDWebImage

class ViewController: UIViewController {
    
    // TODO: more this logic to managers
    var fetchingMoreMedia = false
    
    var mediaGridView: MediaGridView {
        return view as! MediaGridView
    }
    
    func createLogoutButton() -> UIBarButtonItem {
        let result = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutPressed))
        result.tintColor = Styles.tintColor
        return result
    }
    
    override func loadView() {
        view = MediaGridView()
        mediaGridView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateMediaGridView()
        loadMoreMedia()
        
        navigationItem.rightBarButtonItem = createLogoutButton()
    }
    
    func updateMediaGridView() {
        self.mediaGridView.reloadData()
    }
    
    @objc func logoutPressed() {
        InstagramData.shared.authManager.logout()
        self.navigationController?.setViewControllers([LoginViewController()], animated: true)
    }
    
    func loadMoreMedia() {
        guard fetchingMoreMedia == false else {
            return
        }
        fetchingMoreMedia = true
        InstagramData.shared.feedManager.fetchMoreMedia({ [weak self] in
            self?.updateMediaGridView()
            self?.fetchingMoreMedia = false
        }, failure: { [weak self] in
            self?.fetchingMoreMedia = false
        })
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.height {
            loadMoreMedia()
        }
    }
    
}
