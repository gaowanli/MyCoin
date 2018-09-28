//
//  AppDelegate+setting.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/5.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

extension AppDelegate {
    func setupAppearance() {
        setupWindow()
        setupNavgationBar()
        setupTabBar()
        setupSegmentedContorl()
        setupSwitch()
    }
    
    private func setupWindow() {
        window?.layer.cornerRadius = 4.0
        window?.layer.masksToBounds = true
    }
    
    private func setupNavgationBar() {
        let navBar = UINavigationBar.appearance()
        navBar.isTranslucent = false
        navBar.setBackgroundImage(#imageLiteral(resourceName: "nav_bg"), for: .default)
        navBar.shadowImage = UIImage()
    }
    
    private func setupTabBar() {
        let tabBar = UITabBar.appearance()
        tabBar.barStyle = .black // 可达到去黑线的效果
        let tabBarSize = CGSize(width: Constant.screenWidth, height: Constant.tabBarHeight)
        let tabBarImage = UIImage.imageWithColor(.white, size: tabBarSize)
        tabBar.backgroundImage = tabBarImage
        tabBar.shadowImage = #imageLiteral(resourceName: "shadow")
        tabBar.isTranslucent = false
    }
    
    private func setupSegmentedContorl() {
        let segmentedControl = UISegmentedControl.appearance()
        segmentedControl.tintColor = .yellowTintColor
        let attributes = [NSAttributedString.Key.font: UIFont.defalutFont]
        segmentedControl.setTitleTextAttributes(attributes, for: .normal)
    }
    
    private func setupSwitch() {
        let `switch` = UISwitch.appearance()
        `switch`.onTintColor = .yellowTintColor
    }
}
