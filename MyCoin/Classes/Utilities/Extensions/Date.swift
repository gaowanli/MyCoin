//
//  Date.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/17.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation

extension Date {
    static func timestamp() -> Int {
        let d = Date()
        return Int(d.timeIntervalSince1970)
    }
    
    static func dateString() -> String {
        let formatter = Constant.dateFormatter
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: Date())
    }
}
