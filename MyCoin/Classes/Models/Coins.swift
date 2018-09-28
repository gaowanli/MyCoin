//
//  Coins.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/10/27.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation

struct Coins {
    static var staticCoins: [NSDictionary]?
    
    /// 全部币种
    static func allCoins() -> [NSDictionary]? {
        if let c = staticCoins {
            return c
        }
        
        if let p = self.coinsPlistFilePath {
            self.staticCoins = NSArray(contentsOfFile: p) as? [NSDictionary]
        }
        return self.staticCoins
    }
    
    /// 没有数据时默认显示的币种
    static func defaultCoins() -> [NSDictionary]? {
        if let allCoins = allCoins(), allCoins.count > 6 {
            return Array(allCoins[0..<6])
        }
        return nil
    }
    
    /// 通过key 搜索币种
    static func searchCoin(by key: String, exactMatching exact: Bool = false) -> [NSDictionary]? {
        if let allCoins = allCoins() {
            var predicate: NSPredicate!
            if exact {
                predicate = NSPredicate(format: "symbol CONTAINS [c]%@", key)
            } else {
                let strs = key.map({ String($0) }).map({ $0 + "*" })
                let k = strs.joined()
                predicate = NSPredicate(format: "symbol LIKE [c]%@ OR name LIKE [c]%@", k, k)
            }
            return allCoins.filter { predicate.evaluate(with: $0) }
        }
        return nil
    }
    
    private static var coinsPlistFilePath: String? {
        var path: String?
        if UserDefaults.Document.boolValue(.coinsPlistExists) {
            path = LocalData.coinsPlistFilePath
        } else {
            path = Bundle.main.path(forResource: LocalData.coinsPlistFileName, ofType: nil)
        }
        return path
    }
}
