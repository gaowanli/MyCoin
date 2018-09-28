//
//  Appdelegate+defalutSettings.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/5.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation
import UIKit
import Bugly
import LeanCloud
//import IQKeyboardManagerSwift

func defalutSettings() {
    // 货币符号
    if UserDefaults.Settings.stringValue(.currency).isEmpty {
        let all = CurrencySymbol.allSymbolsString()
        if Language.current == .chinese {
            if let c = all.first {
                UserDefaults.Settings.setString(.currency, c)
            }
        } else {
            if all.count > 1 {
                UserDefaults.Settings.setString(.currency, all[1])
            }
        }
    }
    
    // 涨跌周期
    if UserDefaults.Settings.stringValue(.percentChange).isEmpty {
        let p: PercentChange = .oneHour
        UserDefaults.Settings.setString(.percentChange, p.rawValue)
    }
    
    #if !DEBUG
        Bugly.start(withAppId: BuglyConfig.id)
    #endif
    
    LeanCloud.initialize(applicationID: LeanCloudConfig.id,
                         applicationKey: LeanCloudConfig.key)
    
    // IQKeyboardManager.sharedManager().enable = true
    
    // 启动次数
    let startupTimes = UserDefaults.Variable.intValue(.startupTimes)
    UserDefaults.Variable.setInt(.startupTimes, startupTimes + 1)
}
