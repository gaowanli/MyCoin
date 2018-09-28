//
//  DataManager+restore.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/22.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation
import LeanCloud

// MARK:- 恢复所有数据
extension DataManager {
    static func restoreAllData(group: DispatchGroup, userId: String, completion: @escaping (Bool) -> ()) {
        group.enter()
        
        let aGroup = DispatchGroup()
        
        var configure: LCObject?
        queryConfigureData(group: aGroup, userId: userId) { (success, result) in
            if false == success {
                completion(false)
            } else {
                configure = result
            }
        }
        
        var exchanges: [LCObject]?
        queryExchangeData(group: aGroup, userId: userId) { (success, result) in
            if false == success {
                completion(false)
            } else {
                exchanges = result
            }
        }
        
        var wallets: [LCObject]?
        queryWalletData(group: aGroup, userId: userId) { (success, result) in
            if false == success {
                completion(false)
            } else {
                wallets = result
            }
        }
        
        var collections: [LCObject]?
        queryCollectionData(group: aGroup, userId: userId) { (success, result) in
            if false == success {
                completion(false)
            } else {
                collections = result
            }
        }
        
        var coins: [LCObject]?
        queryCoinData(group: aGroup, userId: userId) { (success, result) in
            if false == success {
                completion(false)
            } else {
                coins = result
            }
        }
        
        aGroup.notify(queue: DispatchQueue.main) {
            restoreDataToLocal(group: group, configure: configure, exchanges: exchanges, wallets: wallets, collections: collections, coins: coins) { (success) in
                group.leave()
                if false == success {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
}

// MARK:- 配置数据
extension DataManager {
    private static func queryConfigureData(group: DispatchGroup, userId: String, completion: @escaping ((Bool, LCObject?) -> ())) {
        group.enter()
        
        let query = LCQuery(className: LeanCloudClass.configure)
        query.whereKey(ConfigureClass.userObjectId.column, .equalTo(userId))
        query.getFirst { (result) in
            group.leave()
            completion(result.isSuccess, result.object)
        }
    }
}

// MARK:- 市场数据
extension DataManager {
    private static func queryExchangeData(group: DispatchGroup, userId: String, completion: @escaping ((Bool, [LCObject]?) -> ())) {
        group.enter()
        
        let query = LCQuery(className: LeanCloudClass.exchange)
        query.whereKey(ExchangeClass.userObjectId.column, .equalTo(userId))
        query.find { (result) in
            group.leave()
            completion(result.isSuccess, result.objects)
        }
    }
}

// MARK:- 钱包数据
extension DataManager {
    private static func queryWalletData(group: DispatchGroup, userId: String, completion: @escaping ((Bool, [LCObject]?) -> ())) {
        group.enter()
        
        let query = LCQuery(className: LeanCloudClass.wallet)
        query.whereKey(WalletClass.userObjectId.column, .equalTo(userId))
        query.find { (result) in
            group.leave()
            completion(result.isSuccess, result.objects)
        }
    }
}

// MARK:- 关注数据
extension DataManager {
    private static func queryCollectionData(group: DispatchGroup, userId: String, completion: @escaping ((Bool, [LCObject]?) -> ())) {
        group.enter()
        
        let query = LCQuery(className: LeanCloudClass.collection)
        query.whereKey(CollectionClass.userObjectId.column, .equalTo(userId))
        query.find { (result) in
            group.leave()
            completion(result.isSuccess, result.objects)
        }
    }
}

// MARK:- 资产数据
extension DataManager {
    private static func queryCoinData(group: DispatchGroup, userId: String, completion: @escaping ((Bool, [LCObject]?) -> ())) {
        group.enter()
        
        let query = LCQuery(className: LeanCloudClass.coin)
        query.whereKey(CoinClass.userObjectId.column, .equalTo(userId))
        query.find { (result) in
            group.leave()
            completion(result.isSuccess, result.objects)
        }
    }
}

// MARK:- 恢复数据到本地
extension DataManager {
    private static func restoreDataToLocal(group: DispatchGroup,
                                           configure: LCObject?,
                                           exchanges: [LCObject]?,
                                           wallets: [LCObject]?,
                                           collections: [LCObject]?,
                                           coins: [LCObject]?,
                                           completion: @escaping (Bool) -> ()) {
        guard let config = configure, let e = exchanges, let w = wallets, let co = collections, let c = coins else {
            completion(false)
            return
        }
        let aGroup = DispatchGroup()
        
        let configureResult = restoreConfigureData(group: aGroup, configure: config)
        let exchangeResult = restoreExchangeData(group: aGroup, exchanges: e)
        let walletResult = restoreWalletData(group: aGroup, wallets: w)
        let collectionResult = restoreCollectionData(group: aGroup, collections: co)
        let coinResult = restoreCoinData(group: aGroup, coins: c)
        
        aGroup.notify(queue: DispatchQueue.main) {
            if configureResult, exchangeResult, walletResult, collectionResult, coinResult {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    /// 恢复配置数据
    private static func restoreConfigureData(group: DispatchGroup, configure: LCObject?) -> Bool {
        guard let configureString = configure?.get(ConfigureClass.configure.column)?.stringValue else {
            return false
        }
        group.enter()
        
        let config = configureString.components(separatedBy: "|")
        // 根据'|'拆分
        if config.count >= 4 {
            if let currency = config[0].components(separatedBy: "currency:").last {
                UserDefaults.Settings.setString(.currency, currency)
            }
            if let marketColor = config[1].components(separatedBy: "marketColor:").last {
                if let m = Bool(marketColor) {
                    UserDefaults.Settings.setBool(.marketColor, m)
                }
            }
            if let percentChange = config[2].components(separatedBy: "percentChange:").last {
                UserDefaults.Settings.setString(.percentChange, percentChange)
            }
            if let usdPrice = config[3].components(separatedBy: "usdPrice:").last {
                UserDefaults.Settings.setString(.usdPrice, usdPrice)
            }
            group.leave()
            return true
        } else {
            group.leave()
            return false
        }
    }
    
    /// 恢复市场数据
    private static func restoreExchangeData(group: DispatchGroup, exchanges: [LCObject]) -> Bool {
        group.enter()
        
        // 找出服务器已经删除 但是本地还存在的数据 进行删除操作
        let locaIds = MyExchange.allExchanges().map({ $0.id })
        let serverIds = exchanges.map({ $0.get(ExchangeClass.id.column)?.int32Value ?? 0 })
        let deleteIds = locaIds.filter({ false == serverIds.contains($0) })
        _ = deleteIds.map({ MyExchange.deleteExchange(byId: $0) })
        
        var count = 0
        var success = 0
        for exchange in exchanges {
            if let id = exchange.get(ExchangeClass.id.column)?.int32Value {
                let name = exchange.get(ExchangeClass.name.column)?.stringValue ?? ""
                let remarks = exchange.get(ExchangeClass.remarks.column)?.stringValue ?? ""
                
                count = count + 1
                var result = false
                if let r = MyExchange.exchange(by: id), r.count > 0 {
                    if let objId = r.first?.objectID {
                        result = MyExchange.updateExchange(name: name, remarks: remarks, byId: objId, status: .synchronized)
                    }
                } else {
                    result = MyExchange.addExchange(id: id, name: name, remarks: remarks, status: .synchronized)
                }
                if result {
                    success = success + 1
                }
            }
        }
        group.leave()
        if count > 0, count != success {
            return false
        } else {
            return true
        }
    }
    
    /// 恢复钱包数据
    private static func restoreWalletData(group: DispatchGroup, wallets: [LCObject]) -> Bool {
        group.enter()
        
        // 找出服务器已经删除 但是本地还存在的数据 进行删除操作
        let locaIds = MyWallet.allWallets().map({ $0.id })
        let serverIds = wallets.map({ $0.get(WalletClass.id.column)?.int32Value ?? 0 })
        let deleteIds = locaIds.filter({ false == serverIds.contains($0) })
        _ = deleteIds.map({ MyWallet.deleteWallet(byId: $0) })
        
        var count = 0
        var success = 0
        for wallet in wallets {
            if let id = wallet.get(WalletClass.id.column)?.int32Value {
                let name = wallet.get(WalletClass.name.column)?.stringValue ?? ""
                let remarks = wallet.get(WalletClass.remarks.column)?.stringValue ?? ""
                
                count = count + 1
                var result = false
                if let r = MyWallet.wallet(by: id), r.count > 0 {
                    if let objId = r.first?.objectID {
                        result = MyWallet.updateWallet(name: name, remarks: remarks, byId: objId, status: .synchronized)
                    }
                } else {
                    result = MyWallet.addWallet(id: id, name: name, remarks: remarks, status: .synchronized)
                }
                if result {
                    success = success + 1
                }
            }
        }
        group.leave()
        if count > 0, count != success {
            return false
        } else {
            return true
        }
    }
    
    /// 恢复关注数据
    private static func restoreCollectionData(group: DispatchGroup, collections: [LCObject]) -> Bool {
        group.enter()
        
        // 找出服务器已经删除 但是本地还存在的数据 进行删除操作
        let locaIds = MyCollection.allCollections().map({ $0.id })
        let serverIds = collections.map({ $0.get(CollectionClass.id.column)?.int32Value ?? 0 })
        let deleteIds = locaIds.filter({ false == serverIds.contains($0) })
        _ = deleteIds.map({ MyCollection.deleteCollection(byId: $0) })
        
        var count = 0
        var success = 0
        for collection in collections {
            if let id = collection.get(CollectionClass.id.column)?.int32Value {
                let symbol = collection.get(CollectionClass.symbol.column)?.stringValue
                let name = collection.get(CollectionClass.name.column)?.stringValue
                let sort = collection.get(CollectionClass.sort.column)?.int16Value
                let visible = collection.get(CollectionClass.visible.column)?.boolValue
                
                count = count + 1
                var result = false
                if let r = MyCollection.collection(by: id), r.count > 0 {
                    if let objId = r.first?.objectID, let s = sort, let v = visible {
                        result = MyCollection.updateCollection(sort: s, visible: v, byId: objId)
                    }
                } else {
                    result = MyCollection.addCollection(id: id, sort: sort, visible: visible, symbol: symbol, name: name, status: .synchronized).0
                }
                if result {
                    success = success + 1
                }
            }
        }
        group.leave()
        if count > 0, count != success {
            return false
        } else {
            return true
        }
    }
    
    /// 恢复资产数据
    private static func restoreCoinData(group: DispatchGroup, coins: [LCObject]) -> Bool {
        group.enter()
        
        // 找出服务器已经删除 但是本地还存在的数据 进行删除操作
        let locaIds = MyCoin.allCoins().map({ $0.id })
        let serverIds = coins.map({ $0.get(CoinClass.id.column)?.int32Value ?? 0 })
        let deleteIds = locaIds.filter({ false == serverIds.contains($0) })
        _ = deleteIds.map({ MyCoin.deleteCoin(byId: $0) })
        
        var count = 0
        var success = 0
        for coin in coins {
            if let id = coin.get(CoinClass.id.column)?.int32Value {
                let symbol = coin.get(CoinClass.symbol.column)?.stringValue
                let name = coin.get(CoinClass.name.column)?.stringValue
                let num = coin.get(CoinClass.num.column)?.doubleValue ?? 0.00
                let priceIsTotal = coin.get(CoinClass.unitOrTotal.column)?.boolValue ?? false
                let price = coin.get(CoinClass.buyPrice.column)?.doubleValue ?? 0.00
                let currency = coin.get(CoinClass.currency.column)?.stringValue ?? ""
                let resideIsWallet = coin.get(CoinClass.exchangeOrWallet.column)?.boolValue ?? false
                let reside = coin.get(CoinClass.reside.column)?.stringValue ?? ""
                let buyDate = coin.get(CoinClass.buyDate.column)?.stringValue ?? ""
                let remarks = coin.get(CoinClass.remarks.column)?.stringValue ?? ""
                
                count = count + 1
                var result = false
                if let r = MyCoin.coin(by: id), r.count > 0 {
                    if let objId = r.first?.objectID {
                        result = MyCoin.updateCoin(id: objId, name: name, symbol: symbol, num: num, priceIsTotal: priceIsTotal, price: price, currency: currency, resideIsWallet: resideIsWallet, reside: reside, buyDate: buyDate, remarks: remarks, status: .synchronized)
                    }
                } else {
                    result = MyCoin.addCoin(id: id, name: name, symbol: symbol, num: num, priceIsTotal: priceIsTotal, price: price, currency: currency, resideIsWallet: resideIsWallet, reside: reside, buyDate: buyDate, remarks: remarks, status: .synchronized)
                }
                if result {
                    success = success + 1
                }
            }
        }
        group.leave()
        if count > 0, count != success {
            return false
        } else {
            return true
        }
    }
}
