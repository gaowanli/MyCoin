//
//  AppDelegate.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/10/17.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupAppearance()
        defalutSettings()
        copyPlistToDocumentIfNeed()
        setupRootWindow()
        return true
    }
}
