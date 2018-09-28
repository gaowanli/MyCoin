//
//  NSObject.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/29.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation
import UIKit

extension NSObject {
    func commonLocalizedString(with key: String) -> String {
        return localizedString(with: key, common: true)
    }
    
    func localizedString(with key: String) -> String {
        return localizedString(with: key, common: false)
    }
    
    func setCommonLocalizedString(with label: UILabel, key: String) {
        label.text = commonLocalizedString(with: key)
    }
    
    func setLocalizedString(with label: UILabel, key: String) {
        label.text = localizedString(with: key)
    }
    
    func setLocalizedString(with button: UIButton, key: String, state: UIControl.State? = nil) {
        let title = localizedString(with: key)
        if let s = state {
            button.setTitle(title, for: s)
        } else {
            button.setTitle(title, for: .normal)
        }
    }
    
    func setCommonLocalizedString(with button: UIButton, key: String, state: UIControl.State? = nil) {
        let title = commonLocalizedString(with: key)
        if let s = state {
            button.setTitle(title, for: s)
        } else {
            button.setTitle(title, for: .normal)
        }
    }
    
    private func localizedString(with key: String, common: Bool) -> String {
        var className = ""
        if true == common {
            className = "Common"
        } else {
            className = classString(with: self.classForCoder)
        }
        let k = className + "_" + key
        return Localizations.string(with: k)
    }
    
    private func classString(with aClass: AnyClass) -> String {
        let desc = aClass.description()
        guard desc.contains(".") else {
            return ""
        }
        if let str = desc.components(separatedBy: ".").last {
            return str
        }
        return ""
    }
}
