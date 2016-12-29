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
    
    let userFetcher = UserFetcher()
    var mediaGridView: MediaGridView {
        return self.view as! MediaGridView
    }
    
    override func loadView() {
        self.view = MediaGridView()
        self.mediaGridView.mediaDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global().async {
            let user = self.userFetcher.fetchUser(for: "imben123")
            DispatchQueue.main.async {
                self.mediaGridView.items = user.media.map({ (mediaItem) -> MediaGridViewItem in
                    return MediaGridViewItem(url: mediaItem.thumbnail)
                })
            }
        }
    }
}

extension ViewController: MediaGridViewDelegate {
   
    func mediaGridView(_ sender: MediaGridView, imageForItem item: MediaGridViewItem) -> UIImage? {
        let image = SDImageCache.shared().imageFromMemoryCache(forKey: item.url.absoluteString)
        if let image = image {
            return image
        }
        
        SDWebImageManager.shared().downloadImage(with: item.url, options: [], progress: { (receivedSize, expectedSize) in
            // Nothing
        }, completed: { (image, error, cacheType, finished, url) in
            self.mediaGridView.reloadData()
        })
        
        return nil
    }
}
