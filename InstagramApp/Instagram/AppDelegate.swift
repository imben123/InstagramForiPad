//
//  AppDelegate.swift
//  Instagram
//
//  Created by Ben Davis on 26/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import UIKit
import InstagramData
import SwiftToolbox
import SDWebImage
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let instagramData = InstagramData.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
//        SDImageCache.shared().clearDisk()
//        try! Realm().write { try! Realm().deleteAll() }
        
        let rootViewController: UIViewController
        if InstagramData.shared.authManager.authenticated {
            rootViewController = MainFeedViewController()
        } else {
            rootViewController = LoginViewController()
        }
        
        self.window?.rootViewController = UINavigationController(rootViewController: rootViewController)
        self.window!.backgroundColor = .white
        self.window!.makeKeyAndVisible()
        return true
    }

}

