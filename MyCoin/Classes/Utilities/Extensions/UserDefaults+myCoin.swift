//
//  UserDefaults+myCoin.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/10/30.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation

extension UserDefaults {
    struct Document: UserDefaultsSettable {
        enum UserDefaultKey: String {
            case coinsPlistExists
        }
    }
    
    struct Settings: UserDefaultsSettable {
        enum UserDefaultKey: String {
            case marketColor        // 行情颜色
            case currency           // 货币符号
            case percentChange      // 涨跌周期
            case authentication     // 认证
            case usdPrice           // 显示美元对照
        }
    }
    
    struct UserInfo: UserDefaultsSettable {
        enum UserDefaultKey: String {
            case userName
            case password
        }
    }
    
    struct Variable: UserDefaultsSettable {
        enum UserDefaultKey: String {
            case syncTimestamp      // 数据同步时间
            case plistTimestamp     // Coin.plist时间戳
            case version            // 版本号
            case startupTimes       // 启动次数
            case messageTimestamp   // Message时间戳
            case appleInReview      // 审核中
        }
    }
}
