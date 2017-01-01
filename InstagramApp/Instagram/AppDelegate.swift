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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
//        try! Realm().write { try! Realm().deleteAll() }
        
        let rootViewController: UIViewController
        if InstagramData.shared.authManager.authenticated {
            rootViewController = ViewController()
        } else {
            rootViewController = LoginViewController()
        }
        
        self.window?.rootViewController = UINavigationController(rootViewController: rootViewController)
        self.window!.backgroundColor = .white
        self.window!.makeKeyAndVisible()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url)
        if url.absoluteString.begins(with: "insta-ipad://") {
            return true
        }
        return false
    }

}

