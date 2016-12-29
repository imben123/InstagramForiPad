//
//  AppDelegate.swift
//  Instagram
//
//  Created by Ben Davis on 26/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import UIKit
import SwiftToolbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = ViewController()
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

