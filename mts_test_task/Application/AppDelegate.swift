//
//  AppDelegate.swift
//  mts_test_task
//
//  Created by  Matvey on 08.04.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        let root = RootViewController()
        let nav = UINavigationController(rootViewController: root)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        return true
    }


}

