//
//  CoinPrice.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/9.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation

struct CoinPrice {
    var id: String = ""
    var name: String = ""
    var symbol: String = ""
    var rank: Int = 0
    var price: Double = 0.00
    var priceUSD: Double = 0.00
    var percent1h: Double = 0.00     // 1h价格浮动
    var percent24h: Double = 0.00    // 24h价格浮动
    var percent7d: Double = 0.00     // 7d价格浮动
    var volume24h: Double = 0.00     // 24h成交量
    var marketCap: Double = 0.00     // 市值
    var updatedTime: Double = 0.00   // 更新时间
    
    init(with dict: [String: Any]) {
        let currency = UserDefaults.Settings.stringValue(.currency)
        let convert = currency.lowercased()
        
        if let i = dict["id"] as? String {
            id = i
        }
        if let n = dict["name"] as? String {
            name = n
        }
        if let s = dict["symbol"] as? String {
            symbol = s
        }
        if let r = dict["rank"] as? String, !r.isEmpty {
            rank = Int(r)!
        } else if let r = dict["rank"] as? Int {
            rank = r
        }
        if let p = dict["price_usd"] as? String, !p.isEmpty {
            priceUSD = p.decimalValue()
        } else if let p = dict["price_usd"] as? Double {
            priceUSD = p
        }
        if let p = dict["price_\(convert)"] as? String, !p.isEmpty {
            price = p.decimalValue()
        } else if let p = dict["price_\(convert)"] as? Double {
            price = p
        }
        if let p = dict["percent_change_1h"] as? String, !p.isEmpty {
            percent1h = p.decimalValue()
        } else if let p = dict["percent_change_1h"] as? Double {
            percent1h = p
        }
        if let p = dict["percent_change_24h"] as? String, !p.isEmpty {
            percent24h = p.decimalValue()
        } else if let p = dict["percent_change_24h"] as? Double {
            percent24h = p
        }
        if let p = dict["percent_change_7d"] as? String, !p.isEmpty {
            percent7d = p.decimalValue()
        } else if let p = dict["percent_change_7d"] as? Double {
            percent7d = p
        }
        if let v = dict["24h_volume_\(convert)"] as? String, !v.isEmpty {
            volume24h = v.decimalValue()
        } else if let v = dict["24h_volume_\(convert)"] as? Double {
            volume24h = v
        }
        if let c = dict["market_cap_\(convert)"] as? String, !c.isEmpty {
            marketCap = c.decimalValue()
        } else if let c = dict["market_cap_\(convert)"] as? Double {
            marketCap = c
        }
        if let u = dict["last_updated"] as? String, !u.isEmpty {
            updatedTime = u.decimalValue()
        } else if let u = dict["last_updated"] as? Double {
            updatedTime = u
        }
    }
    
    /// 请求价格
    static func fetchPrice(symbol: String, name: String, currency: String, completion: ((String, String, CoinPrice?, Bool) -> ())?) {
        let url = Api.tickerUrl + "\(name)/?convert=\(currency)"
        
        NetworkManager.share.requestJSON(url: url, method: .get, parameters: nil) { (data, success, error) in
            if let array = data as? [[String: String]], array.count > 0 {
                let dict = array[0]
                if let error = dict["error"], !error.isEmpty {
                    completion?(symbol, currency, nil, false)
                } else {
                    let coinPrice = CoinPrice(with: dict)
                    completion?(symbol, currency, coinPrice, success)
                }
            } else {
                if let array = data as? [Any], array.count > 0 {
                    if let dict = array[0] as? [String: Any] {
                        let coinPrice = CoinPrice(with: dict)
                        completion?(symbol, currency, coinPrice, success)
                    } else {
                        reporError(url: url, error: error)
                        completion?(symbol, currency, nil, false)
                    }
                } else {
                    reporError(url: url, error: error)
                    completion?(symbol, currency, nil, false)
                }
            }
        }
    }
    
    private static func reporError(url: String, error: String?) {
        var message = url
        if let e = error {
            message = message + e
        }
        ErrorManager.reportError(code: .priceFail, message: message)
    }
}
