//
//  AppDelegate+rootWindow.swift
//  MyCoin
//
//  Created by GaoWanli on 11/02/2018.
//  Copyright © 2018 wl. All rights reserved.
//

import UIKit

extension AppDelegate {
    func setupRootWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let auth = UserDefaults.Settings.boolValue(.authentication)
        let notEnrolled = (false == UIDevice.supportFaceID && false == UIDevice.supportTouchID)
        if true == notEnrolled || false == auth {
            UserDefaults.Settings.setBool(.authentication, false)
            let vc = UIStoryboard.load(from: .main, withId: .tabBar)
            window?.rootViewController = vc
        } else {
            let vc = UIStoryboard.load(from: .main, withId: .auth)
            window?.rootViewController = vc
        }
        window?.makeKeyAndVisible()
        NotificationCenter.default.addObserver(self, selector: #selector(changeRootVCToTabBarController), name: .rootVCToTabBarVC, object: nil)
    }
    
    @objc private func changeRootVCToTabBarController() {
        let vc = UIStoryboard.load(from: .main, withId: .tabBar)
        window?.rootViewController = vc
    }
}
