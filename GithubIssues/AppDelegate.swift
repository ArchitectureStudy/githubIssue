//
//  AppDelegate.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 9..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if !GlobalState.instance.isLoggedIn {
            let loginViewController = LoginViewController.viewController
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: { [weak self] in
                self?.window?.rootViewController?.present(loginViewController, animated: false, completion: nil)
            })
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {

    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print("url: \(url.absoluteString)")
        if (url.host == "oauth-callback") {
            OAuthSwift.handle(url: url)
        }
        return true
    }
}
