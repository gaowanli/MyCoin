//
//  NavigationController.swift
//  MyCoin
//
//  Created by GaoWanli on 2018/02/05.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let _ = topViewController as? DefaultStatusBarStyle {
            return .default
        }else {
            return .lightContent
        }
    }
    
    override var childForStatusBarStyle: UIViewController? {
        if let vc = topViewController as? ChangeStatusBarStyle {
            if vc.needChange {
                return topViewController
            }else {
                return nil
            }
        }else {
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isNavigationBarHidden = true
        interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if (self.viewControllers.count > 0) {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: true)
    }
}
