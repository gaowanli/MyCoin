//
//  Notification+myCoin.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/6/7.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation
import UIKit

extension Notification.Name {
    static let textFieldTextDidChange   = UITextField.textDidChangeNotification
    static let textViewTextDidChange    = UITextView.textDidChangeNotification
    static let autoRestoreDataSuccess   = NSNotification.Name("AutoRestoreDataSuccess")
    static let rootVCToTabBarVC         = NSNotification.Name("rootVCToTabBarVC")
}
