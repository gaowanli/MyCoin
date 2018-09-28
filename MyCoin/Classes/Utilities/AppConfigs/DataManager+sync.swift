//
//  DataManager+sync.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/22.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation
import LeanCloud

// MARK:- 同步所有数据
extension DataManager {
    static func syncAllData(group: DispatchGroup, userIdString: String, completion: @escaping (Bool) -> ()) {
        syncConfigureData(group: group, userId: userIdString, completion: completion)
        syncExchangeData(group: group, userId: userIdString, completion: completion)
        syncWalletData(group: group, userId: userIdString, completion: completion)
        syncCollectionData(group: group, userId: userIdString, completion: completion)
        syncCoinData(group: group, userId: userIdString, completion: completion)
    }
}

// MARK:- 同步配置数据
extension DataManager {
    private static func syncConfigureData(group: DispatchGroup, userId: String, completion: @escaping (Bool) -> ()) {
        group.enter()
        
        let query = LCQuery(className: LeanCloudClass.configure)
        query.whereKey(ConfigureClass.userObjectId.column, .equalTo(userId))
        query.getFirst { (result) in
            var configure: LCObject?
            if let r = result.object {
                configure = r
            } else {
                configure = LCObject(className: LeanCloudClass.configure)
            }
            
            if let c = configure {
                c.set(ConfigureClass.userObjectId.column, value: userId)
                c.set(ConfigureClass.configure.column, value: configureString())
                
                c.save({ (result) in
                    group.leave()
                    completion(result.isSuccess)
                })
            } else {
                group.leave()
                completion(false)
            }
        }
    }
    
    private static func configureString() -> String {
        let currency = UserDefaults.Settings.stringValue(.currency)
        let marketColor = UserDefaults.Settings.boolValue(.marketColor)
        let percentChange = UserDefaults.Settings.stringValue(.percentChange)
        let usdPrice = UserDefaults.Settings.boolValue(.usdPrice)
        let s = "currency:\(currency)|marketColor:\(marketColor)|percentChange:\(percentChange)|usdPrice:\(usdPrice)"
        return s
    }
}

// MARK:- 同步市场数据
extension DataManager {
    private static func syncExchangeData(group: DispatchGroup, userId: String, completion: @escaping (Bool) -> ()) {
        group.enter()
        
        let all = MyExchange.allNeedSyncExchanges()
        let count = all.count
        var runTime = count / once
        let last = Double(count).truncatingRemainder(dividingBy: Double(once))
        if last > 0 {
            runTime = runTime + 1
        }
        
        let aGroup = DispatchGroup()
        batchesSyncExchange(all: all, count: count, once: once, runTime: runTime, run: 0, group: aGroup, userId: userId, error: false, completion: { (success) in
            group.leave()
            completion(success)
        })
    }
    
    private static func batchesSyncExchange(all: [Exchange], count: Int, once: Int, runTime: Int, run: Int, group: DispatchGroup, userId: String, error: Bool, completion: @escaping (Bool) -> ()) {
        if error {
            completion(false)
            return
        } else if run == runTime {
            completion(true)
            return
        }
        
        var current = ArraySlice<Exchange>()
        if run == runTime - 1 {
            let begin = once * run
            current = all[begin..<count]
        } else {
            let begin = once * run
            let end = once * (run + 1)
            current = all[begin..<end]
        }
        
        let aGroup = DispatchGroup()
        var aError = false
        for item in current {
            aGroup.enter()
            
            let status = EntityStatus(rawValue: item.status)
            if status == .insert {
                let exchange = LCObject(className: LeanCloudClass.exchange)
                exchange.set(ExchangeClass.userObjectId.column, value: userId)
                exchange.set(ExchangeClass.name.column, value: item.name)
                exchange.set(ExchangeClass.remarks.column, value: item.remarks)
                exchange.set(ExchangeClass.id.column, value: item.id)
                
                exchange.save({ (result) in
                    aGroup.leave()
                    if result.isFailure {
                        aError = true
                        return
                    } else {
                        MyExchange.updateExchangeStatusToSynchronized(byId: item.objectID)
                    }
                })
            } else if status == .delete || status == .update {
                let query = LCQuery(className: LeanCloudClass.exchange)
                query.whereKey(ExchangeClass.userObjectId.column, .equalTo(userId))
                query.whereKey(ExchangeClass.id.column, .equalTo(item.id))
                query.getFirst { (result) in
                    if let exchange = result.object {
                        if status == .delete {
                            exchange.delete({ (result) in
                                aGroup.leave()
                                if result.isFailure {
                                    aError = true
                                    return
                                } else {
                                    MyExchange.updateExchangeStatusToSynchronized(byId: item.objectID, delete: true)
                                }
                            })
                        } else {
                            exchange.set(ExchangeClass.name.column, value: item.name)
                            exchange.set(ExchangeClass.remarks.column, value: item.remarks)
                            exchange.save({ (result) in
                                aGroup.leave()
                                if result.isFailure {
                                    aError = true
                                    return
                                } else {
                                    MyExchange.updateExchangeStatusToSynchronized(byId: item.objectID)
                                }
                            })
                        }
                    } else {
                        aGroup.leave()
                        if result.isFailure {
                            aError = true
                            return
                        }
                    }
                }
            } else {
                aGroup.leave()
                aError = true
                break
            }
        }
        aGroup.notify(queue: DispatchQueue.main) {
            batchesSyncExchange(all: all, count: count, once: once, runTime: runTime, run: run + 1, group: aGroup, userId: userId, error: aError, completion: completion)
        }
    }
}

// MARK:- 同步钱包数据
extension DataManager {
    private static func syncWalletData(group: DispatchGroup, userId: String, completion: @escaping (Bool) -> ()) {
        group.enter()
        
        let all = MyWallet.allNeedSyncWallets()
        let count = all.count
        var runTime = count / once
        let last = Double(count).truncatingRemainder(dividingBy: Double(once))
        if last > 0 {
            runTime = runTime + 1
        }
        
        let aGroup = DispatchGroup()
        batchesSyncWallet(all: all, count: count, once: once, runTime: runTime, run: 0, group: aGroup, userId: userId, error: false, completion: { (success) in
            group.leave()
            completion(success)
        })
    }
    
    private static func batchesSyncWallet(all: [Wallet], count: Int, once: Int, runTime: Int, run: Int, group: DispatchGroup, userId: String, error: Bool, completion: @escaping (Bool) -> ()) {
        if error {
            completion(false)
            return
        } else if run == runTime {
            completion(true)
            return
        }
        
        var current = ArraySlice<Wallet>()
        if run == runTime - 1 {
            let begin = once * run
            current = all[begin..<count]
        } else {
            let begin = once * run
            let end = once * (run + 1)
            current = all[begin..<end]
        }
        
        let aGroup = DispatchGroup()
        var aError = false
        for item in current {
            aGroup.enter()
            
            let status = EntityStatus(rawValue: item.status)
            if status == .insert {
                let wallet = LCObject(className: LeanCloudClass.wallet)
                wallet.set(WalletClass.userObjectId.column, value: userId)
                wallet.set(WalletClass.name.column, value: item.name)
                wallet.set(WalletClass.remarks.column, value: item.remarks)
                wallet.set(WalletClass.id.column, value: item.id)
                
                wallet.save({ (result) in
                    aGroup.leave()
                    if result.isFailure {
                        aError = true
                        return
                    } else {
                        MyWallet.updateWalletStatusToSynchronized(byId: item.objectID)
                    }
                })
            } else if status == .delete || status == .update {
                let query = LCQuery(className: LeanCloudClass.wallet)
                query.whereKey(WalletClass.userObjectId.column, .equalTo(userId))
                query.whereKey(WalletClass.id.column, .equalTo(item.id))
                query.getFirst { (result) in
                    if let wallet = result.object {
                        if status == .delete {
                            wallet.delete({ (result) in
                                aGroup.leave()
                                if result.isFailure {
                                    aError = true
                                    return
                                } else {
                                    MyWallet.updateWalletStatusToSynchronized(byId: item.objectID, delete: true)
                                }
                            })
                        } else {
                            wallet.set(WalletClass.name.column, value: item.name)
                            wallet.set(WalletClass.remarks.column, value: item.remarks)
                            wallet.save({ (result) in
                                aGroup.leave()
                                if result.isFailure {
                                    aError = true
                                    return
                                } else {
                                    MyWallet.updateWalletStatusToSynchronized(byId: item.objectID)
                                }
                            })
                        }
                    } else {
                        aGroup.leave()
                        if result.isFailure {
                            aError = true
                            return
                        }
                    }
                }
            } else {
                aGroup.leave()
                aError = true
                break
            }
        }
        aGroup.notify(queue: DispatchQueue.main) {
            batchesSyncWallet(all: all, count: count, once: once, runTime: runTime, run: run + 1, group: aGroup, userId: userId, error: aError, completion: completion)
        }
    }
}

// MARK:- 同步关注数据
extension DataManager {
    private static func syncCollectionData(group: DispatchGroup, userId: String, completion: @escaping (Bool) -> ()) {
        group.enter()
        
        let all = MyCollection.allNeedSyncCollections()
        let count = all.count
        var runTime = count / once
        let last = Double(count).truncatingRemainder(dividingBy: Double(once))
        if last > 0 {
            runTime = runTime + 1
        }
        
        let aGroup = DispatchGroup()
        batchesSyncCollection(all: all, count: count, once: once, runTime: runTime, run: 0, group: aGroup, userId: userId, error: false, completion: { (success) in
            group.leave()
            completion(success)
        })
    }
    
    private static func batchesSyncCollection(all: [Collection], count: Int, once: Int, runTime: Int, run: Int, group: DispatchGroup, userId: String, error: Bool, completion: @escaping (Bool) -> ()) {
        if error {
            completion(false)
            return
        } else if run == runTime {
            completion(true)
            return
        }
        
        var current = ArraySlice<Collection>()
        if run == runTime - 1 {
            let begin = once * run
            current = all[begin..<count]
        } else {
            let begin = once * run
            let end = once * (run + 1)
            current = all[begin..<end]
        }
        
        let aGroup = DispatchGroup()
        var aError = false
        for item in current {
            aGroup.enter()
            
            let status = EntityStatus(rawValue: item.status)
            if status == .insert {
                let collection = LCObject(className: LeanCloudClass.collection)
                collection.set(CollectionClass.id.column, value: item.id)
                collection.set(CollectionClass.userObjectId.column, value: userId)
                collection.set(CollectionClass.symbol.column, value: item.symbol)
                collection.set(CollectionClass.name.column, value: item.name)
                collection.set(CollectionClass.sort.column, value: item.sort)
                collection.set(CollectionClass.visible.column, value: (item.visible ? 1 : 0))
                
                collection.save({ (result) in
                    aGroup.leave()
                    if result.isFailure {
                        aError = true
                        return
                    } else {
                        MyCollection.updateCollectionStatusToSynchronized(byId: item.objectID)
                    }
                })
            } else if status == .delete || status == .update {
                let query = LCQuery(className: LeanCloudClass.collection)
                query.whereKey(CollectionClass.userObjectId.column, .equalTo(userId))
                query.whereKey(CollectionClass.id.column, .equalTo(item.id))
                query.getFirst { (result) in
                    if let collection = result.object {
                        if status == .delete {
                            collection.delete({ (result) in
                                aGroup.leave()
                                if result.isFailure {
                                    aError = true
                                    return
                                } else {
                                    MyCollection.updateCollectionStatusToSynchronized(byId: item.objectID, delete: true)
                                }
                            })
                        } else {
                            collection.set(CollectionClass.id.column, value: item.id)
                            collection.set(CollectionClass.userObjectId.column, value: userId)
                            collection.set(CollectionClass.symbol.column, value: item.symbol)
                            collection.set(CollectionClass.name.column, value: item.name)
                            collection.set(CollectionClass.sort.column, value: item.sort)
                            collection.set(CollectionClass.visible.column, value: (item.visible ? 1 : 0))
                            collection.save({ (result) in
                                aGroup.leave()
                                if result.isFailure {
                                    aError = true
                                    return
                                } else {
                                    MyCollection.updateCollectionStatusToSynchronized(byId: item.objectID)
                                }
                            })
                        }
                    } else {
                        aGroup.leave()
                        if result.isFailure {
                            aError = true
                            return
                        }
                    }
                }
            } else {
                aGroup.leave()
                aError = true
                break
            }
        }
        aGroup.notify(queue: DispatchQueue.main) {
            batchesSyncCollection(all: all, count: count, once: once, runTime: runTime, run: run + 1, group: aGroup, userId: userId, error: aError, completion: completion)
        }
    }
}

// MARK:- 同步资产数据
extension DataManager {
    private static func syncCoinData(group: DispatchGroup, userId: String, completion: @escaping (Bool) -> ()) {
        group.enter()
        
        let all = MyCoin.allNeedSyncCoins()
        let count = all.count
        var runTime = count / once
        let last = Double(count).truncatingRemainder(dividingBy: Double(once))
        if last > 0 {
            runTime = runTime + 1
        }
        
        let aGroup = DispatchGroup()
        batchesSyncCoin(all: all, count: count, once: once, runTime: runTime, run: 0, group: aGroup, userId: userId, error: false, completion: { (success) in
            group.leave()
            completion(success)
        })
    }
    
    private static func batchesSyncCoin(all: [Coin], count: Int, once: Int, runTime: Int, run: Int, group: DispatchGroup, userId: String, error: Bool, completion: @escaping (Bool) -> ()) {
        if error {
            completion(false)
            return
        } else if run == runTime {
            completion(true)
            return
        }
        
        var current = ArraySlice<Coin>()
        if run == runTime - 1 {
            let begin = once * run
            current = all[begin..<count]
        } else {
            let begin = once * run
            let end = once * (run + 1)
            current = all[begin..<end]
        }
        
        let aGroup = DispatchGroup()
        var aError = false
        for item in current {
            aGroup.enter()
            
            let status = EntityStatus(rawValue: item.status)
            if status == .insert {
                let coin = LCObject(className: LeanCloudClass.coin)
                coin.set(CoinClass.id.column, value: item.id)
                coin.set(CoinClass.userObjectId.column, value: userId)
                coin.set(CoinClass.name.column, value: item.name)
                coin.set(CoinClass.symbol.column, value: item.symbol)
                coin.set(CoinClass.num.column, value: item.num)
                coin.set(CoinClass.reside.column, value: item.reside)
                coin.set(CoinClass.exchangeOrWallet.column, value: (item.resideIsWallet ? 1 : 0))
                coin.set(CoinClass.buyPrice.column, value: item.price)
                coin.set(CoinClass.unitOrTotal.column, value: (item.priceIsTotal ? 1 : 0))
                coin.set(CoinClass.currency.column, value: item.currency)
                coin.set(CoinClass.buyDate.column, value: item.buyDate)
                coin.set(CoinClass.remarks.column, value: item.remarks)
                
                coin.save({ (result) in
                    aGroup.leave()
                    if result.isFailure {
                        aError = true
                        return
                    } else {
                        MyCoin.updateCoinStatusToSynchronized(byId: item.objectID)
                    }
                })
            } else if status == .delete || status == .update {
                let query = LCQuery(className: LeanCloudClass.coin)
                query.whereKey(CollectionClass.userObjectId.column, .equalTo(userId))
                query.whereKey(CollectionClass.id.column, .equalTo(item.id))
                query.getFirst { (result) in
                    if let coin = result.object {
                        if status == .delete {
                            coin.delete({ (result) in
                                aGroup.leave()
                                if result.isFailure {
                                    aError = true
                                    return
                                } else {
                                    MyCoin.updateCoinStatusToSynchronized(byId: item.objectID, delete: true)
                                }
                            })
                        } else {
                            coin.set(CoinClass.id.column, value: item.id)
                            coin.set(CoinClass.userObjectId.column, value: userId)
                            coin.set(CoinClass.name.column, value: item.name)
                            coin.set(CoinClass.symbol.column, value: item.symbol)
                            coin.set(CoinClass.num.column, value: item.num)
                            coin.set(CoinClass.reside.column, value: item.reside)
                            coin.set(CoinClass.exchangeOrWallet.column, value: (item.resideIsWallet ? 1 : 0))
                            coin.set(CoinClass.buyPrice.column, value: item.price)
                            coin.set(CoinClass.unitOrTotal.column, value: (item.priceIsTotal ? 1 : 0))
                            coin.set(CoinClass.currency.column, value: item.currency)
                            coin.set(CoinClass.buyDate.column, value: item.buyDate)
                            coin.set(CoinClass.remarks.column, value: item.remarks)
                            
                            coin.save({ (result) in
                                aGroup.leave()
                                if result.isFailure {
                                    aError = true
                                    return
                                } else {
                                    MyCoin.updateCoinStatusToSynchronized(byId: item.objectID)
                                }
                            })
                        }
                    } else {
                        aGroup.leave()
                        if result.isFailure {
                            aError = true
                            return
                        }
                    }
                }
            } else {
                aGroup.leave()
                aError = true
                break
            }
        }
        aGroup.notify(queue: DispatchQueue.main) {
            batchesSyncCoin(all: all, count: count, once: once, runTime: runTime, run: run + 1, group: aGroup, userId: userId, error: aError, completion: completion)
        }
    }
}
