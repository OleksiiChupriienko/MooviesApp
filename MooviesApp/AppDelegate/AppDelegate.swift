//
//  AppDelegate.swift
//  MooviesApp
//
//  Created by Aleksei Chupriienko on 09.09.2020.
//  Copyright © 2020 Andersen. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mooviesListVC = storyboard.instantiateInitialViewController() as? MooviesListController {
            mooviesListVC.mooviesAPI = MooviesAPI()
            window = UIWindow(frame: UIScreen.main.bounds)
                    window?.rootViewController = UINavigationController(rootViewController: mooviesListVC)
            window?.makeKeyAndVisible()
        }
        return true
    }

}
