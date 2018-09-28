//
//  CollectionCoin.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/25.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation
import CoreData

struct CollectionCoin {
    var collectionId: Int32 = 0
    var symbol: String = ""
    var name: String = ""
    var num: Double = 0.00
    var cachePrice: CoinCachePrice?
    var coins: [Coin]?
    
    static func allCollectionCoins() -> [CollectionCoin] {
        let allColletion = MyCollection.visibleCollections()
        
        var collectionCoins: [CollectionCoin] = []
        for collection in allColletion {
            let id = collection.id
            let symbol = collection.symbol
            let name = collection.name
            
            if let s = symbol, let n = name {
                let currency = UserDefaults.Settings.stringValue(.currency)
                let cachePrice = CoinCachePrice.priceCache(by: s, name: n, currency: currency.lowercased())
                let coins = self.coins(by: s, andName: n)
                let collectionCoin = CollectionCoin(collectionId: id, symbol: s, name: n, num: coins.1, cachePrice: cachePrice, coins: coins.0)
                collectionCoins.append(collectionCoin)
            }
        }
        return collectionCoins
    }
    
    static func coins(by symbol: String, andName name: String) -> ([Coin]?, Double) {
        let request = NSFetchRequest<Coin>(entityName: Entity.coin)
        request.predicate = NSPredicate(format: "symbol = %@ AND name = %@ AND status != %d", symbol, name, EntityStatus.delete.rawValue)
        do {
            let result = try Constant.context.fetch(request)
            var num = 0.00
            for coin in result {
                num = num + coin.num
            }
            return (result, num)
        } catch {
            return ([], 0.00)
        }
    }
}
