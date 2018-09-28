//
//  CoinCachePrice.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/12/1.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation

struct CoinCachePrice {
    //var
    var price: Double = 0.00
    var priceUSD: Double = 0.00
    var percent1h: Double = 0.00
    var percent24h: Double = 0.00
    var percent7d: Double = 0.00
    
    /// 查询缓存记录
    static func priceCache(by symbol: String, name: String, currency: String) -> CoinCachePrice? {
        if let reslut = MyPriceCache.priceCache(by: symbol, name: name, currency: currency) {
            return CoinCachePrice(price: reslut.price, priceUSD: reslut.priceUSD, percent1h: reslut.percent1h, percent24h: reslut.percent24h, percent7d: reslut.percent7d)
        } else {
            return nil
        }
    }
}
