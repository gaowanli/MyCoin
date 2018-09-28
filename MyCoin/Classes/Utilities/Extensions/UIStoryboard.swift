//
//  UIStoryboard.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/6/7.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func load(from storyboard: Storyboard, withId id: Identifier? = nil) -> UIViewController {
        let sb = UIStoryboard(name: storyboard.rawValue, bundle: nil)
        if let id = id?.rawValue {
            return sb.instantiateViewController(withIdentifier: id)
        } else {
            return sb.instantiateInitialViewController()!
        }
    }
}
