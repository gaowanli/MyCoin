//
//  DHButton.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/13.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

/// 取消高亮的button
class DHButton: UIButton {
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            super.isHighlighted = false
        }
    }
}
