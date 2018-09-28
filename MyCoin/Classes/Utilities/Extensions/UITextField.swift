//
//  UITextField.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/6.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

/// 禁用复制、粘贴、选择等功能的文本框
class TextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
