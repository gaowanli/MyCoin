//
//  Config.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/6/7.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation
import UIKit

struct BuglyConfig {
    static let id   = ""
}

struct Api {
    static let tickerUrl = "https://api.coinmarketcap.com/v1/ticker/"
}

struct AppStore {
    static let downloadUrl = "https://itunes.apple.com/us/app/mycoin-btc-eth-accounting-app/id1315976679?l=zh&ls=1&mt=8"
}

struct Coinmarketcap {
    static let currenciesUrl = "https://coinmarketcap.com/currencies/"
}

struct ClouddnConfig {
    static let plistUrl = "http://p0f3enyvr.bkt.clouddn.com/Coins.plist"
}

struct LeanCloudConfig {
    static let id   = ""
    static let key  = ""
}

struct Developer {
    static let email    = ""
    static let userId   = ""
}

struct Entity {
    static let collection   = "Collection"
    static let coin         = "Coin"
    static let wallet       = "Wallet"
    static let exchange     = "Exchange"
    static let priceCache   = "PriceCache"
}

struct LocalData {
    static let coinsPlistFileName = "Coins.plist"
    
    static var coinsPlistFilePath: String? {
        get {
            var path: String?
            
            let file = LocalData.coinsPlistFileName
            let document = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            if let `document` = document {
                path = `document` + "/\(file)"
            }
            
            return path
        }
    }
}

/// 货币符号
enum CurrencySymbol: String {
    case cny    // 人民币
    case usd    // 美元
    case btc    // BTC
    case eth    // ETH
    case eur    // 欧元
    case gbp    // 英镑
    case chf    // 瑞士法郎
    case cad    // 加拿大元
    case rub    // 俄罗斯卢布
    case aud    // 澳大利亚亚元
    case brl    // 巴西雷亚尔
    case krw    // 韩元
    case sgd    // 新加坡元
    case jpy    // 日元
    case hkd    // 港币
    case twd    // 台币
    case myr    // 马来西亚林吉特
    case dkk    // 丹麦克朗
    case pln    // 波兰兹罗提
    case mxn    // 墨西哥元
    case sek    // 瑞典克朗
    case huf    // 匈牙利福林
    case nok    // 挪威克朗
    case thb    // 泰铢
    case clp    // 智利比索
    case idr    // 印尼卢比
    case nzd    // 新西兰元
    case ils    // 以色列新锡克尔
    case php    // 菲律宾比索
    case czk    // 捷克克朗
    case inr    // 印度卢比
    case pkr    // 巴基斯坦卢比
    case zar    // 南非兰特
    
    var symbol: String {
        return self.rawValue
    }
    
    private static var symbolIcons: [CurrencySymbol: String] {
        return [.cny: "¥", .usd: "$", .btc: "btc", .eth: "eth", .eur: "€", .gbp: "￡", .chf: "Fr.", .cad: "C$",
                .rub: "₽", .aud: "$A", .brl: "R$", .krw: "₩", .sgd: "S$", .jpy: "J¥", .hkd: "HK$", .twd: "NT$",
                .myr: "MYR", .dkk: "kr.", .pln: "zł7 ", .mxn: "$", .sek: "kr", .huf: "Ft", .nok: "kr", .thb: "฿",
                .clp: "$", .idr: "Rp", .nzd: "$", .ils: "₪", .php: "₱", .czk: "Kč", .inr: "₹", .pkr: "₨",
                .zar: "R"]
    }
    
    static func allSymbolsString() -> [String] {
        let allSymbols = CurrencySymbol.allSymbols()
        var all = [String]()
        for symbol in allSymbols {
            all.append(symbol.rawValue.uppercased())
        }
        return all
    }
    
    static func icon(symbol: CurrencySymbol) -> String {
        return symbolIcons[symbol] ?? ""
    }
    
    /// 当前货币符号
    static func current() -> String {
        let currency = UserDefaults.Settings.stringValue(.currency).lowercased()
        if currency.isEmpty {
            return "$"
        }
        return icon(symbol: CurrencySymbol(rawValue: currency)!)
    }
    
    private static func allSymbols() -> [CurrencySymbol] {
        return [.cny, .usd, .btc, .eth, .eur, .gbp, .chf, .cad,
                .rub, .aud, .brl, .krw, .sgd, .jpy, .hkd, .twd,
                .myr, .dkk, .pln, .mxn, .sek, .huf, .nok, .thb,
                .clp, .idr, .nzd, .ils, .php, .czk, .inr, .pkr,
                .zar]
    }
}

/// 涨跌周期
enum PercentChange: String {
    case oneHour        = "percent_change_1h"
    case twentyFourHour = "percent_change_24h"
    case sevenDay       = "percent_change_7d"
    
    var percent: String {
        return self.rawValue
    }
}

/// 页面编辑模式
enum PageEditMode {
    case add            // 添加
    case targetedAdd    // 针对性的添加
    case edit           // 编辑
}

struct CommonLocalizedKey {
    static let syncTips = "SyncDataTips"
    static let syncSuccess = "SyncDataSuccess"
    static let syncErrorRetry = "SyncDataErrorRetry"
    static let signIn = "SignIn"
    static let signUp = "SignUp"
    static let findPassword = "FindPassword"
    static let logOut = "LogOut"
    static let logOutTips = "LogOutTips"
    static let syncErrorLogOut = "SyncDataErrorLogOut"
    static let faceID = "FaceID"
    static let touchID = "TouchID"
    static let errorRetry = "ErrorRetry"
    static let checkInput = "CheckInput"
    static let assets = "Assets"
    static let settings = "Settings"
    static let currency = "Currency"
    static let collection = "MyCollection"
    static let percentChange = "PercentChange"
    static let wallet = "Wallet"
    static let exchange = "Exchange"
    static let myWallet = "MyWallet"
    static let myExchange = "MyExchange"
    static let delete = "Delete"
    static let deleteSuccess = "DeleteSuccess"
    static let save = "Save"
    static let oneHour = "OneHour"
    static let twentyFourHour = "TwentyFourHour"
    static let sevenDay = "SevenDay"
    static let select = "Select"
    static let search = "Search"
    static let unitPrice = "UnitPrice"
    static let totalPrice = "TotalPrice"
    static let authTips = "AuthTips"
    static let cancel = "Cancel"
    static let confirm = "Confirm"
    static let feedback = "Feedback"
}

struct AppInfo {
    static var version: String {
        guard let appInfo = AppInfo.info else {
            return ""
        }
        return ((appInfo["CFBundleShortVersionString"] as? String) ?? "")
    }
    
    static var build: String {
        guard let appInfo = AppInfo.info else {
            return ""
        }
        return (appInfo[kCFBundleVersionKey as String] as? String ?? "")
    }
    
    private static var info: [String : Any]? {
        let info = Bundle.main.infoDictionary
        return info
    }
}
