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
    
    var dataSource: InstagramFeedDataSource!
    
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
        dataSource = InstagramFeedDataSource(mediaGridView: mediaGridView)
        mediaGridView.dataSource = dataSource
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        updateMediaGridView()
        dataSource.loadMoreMedia()
        
        navigationItem.rightBarButtonItem = createLogoutButton()
    }
    
    func updateMediaGridView() {
        self.mediaGridView.reloadData()
    }
    
    @objc func logoutPressed() {
        InstagramData.shared.authManager.logout()
        self.navigationController?.setViewControllers([LoginViewController()], animated: true)
    }
}
