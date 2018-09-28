//
//  ErrorManager.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/22.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation
import Bugly

enum ErrorCode: Int {
    case syncFail       = 999901    // 数据同步失败
    case restoreFail    = 999902    // 数据恢复失败
    case signInFail     = 999903    // 登陆失败
    case signUpFail     = 999904    // 注册失败
    case plistFail      = 999905    // plist下载失败
    case priceFail      = 999906    // 价格请求失败
    case feedbackFail   = 999907    // 意见反馈提交失败
}

struct ErrorManager {
    static func reportError(code: ErrorCode, message: String = "") {
        Bugly.reportException(withCategory: 3, name: "MyCoin Error", reason: "\(code.rawValue):" + message, callStack: [], extraInfo: [:], terminateApp: false)
    }
}
