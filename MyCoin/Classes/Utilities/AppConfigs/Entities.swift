//
//  Entity.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/7.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation
import CoreData

enum EntityStatus: Int16 {
    case unknow
    case synchronized   // 已同步
    case insert         // 新增的数据
    case delete         // 已删除的数据
    case update         // 已修改的数据
}

struct MyExchange {
    /// 所有数据
    static func allExchanges() -> [Exchange] {
        let request = NSFetchRequest<Exchange>(entityName: Entity.exchange)
        request.predicate = NSPredicate(format: "status != %d", EntityStatus.delete.rawValue)
        do {
            let result = try Constant.context.fetch(request)
            return result
        } catch {
            return []
        }
    }
    
    /// 所有未同步的数据
    static func allNeedSyncExchanges() -> [Exchange] {
        let request = NSFetchRequest<Exchange>(entityName: Entity.exchange)
        request.predicate = NSPredicate(format: "status != %d", EntityStatus.synchronized.rawValue)
        do {
            let result = try Constant.context.fetch(request)
            return result
        } catch {
            return []
        }
    }
    
    /// 根据id查询数据
    static func exchange(by id: Int32) -> [Exchange]? {
        let request = NSFetchRequest<Exchange>(entityName: Entity.exchange)
        request.predicate = NSPredicate(format: "id == %d", id)
        do {
            let result = try Constant.context.fetch(request)
            return result
        } catch {
            return []
        }
    }
    
    /// 添加
    static func addExchange(id: Int32? = nil, name: String, remarks: String?, status: EntityStatus? = nil) -> Bool {
        do {
            let exchange = NSEntityDescription.insertNewObject(forEntityName: Entity.exchange, into: Constant.context) as! Exchange
            
            if let i = id {
                exchange.id = i
            } else {
                exchange.id = Int32(Date.timestamp())
            }
            if let s = status {
                exchange.status = s.rawValue
            } else {
                exchange.status = EntityStatus.insert.rawValue
            }
            exchange.name = name
            exchange.remarks = (remarks ?? "")
            try Constant.context.save()
            return true
        } catch {
            return false
        }
    }
    
    /// 更新
    static func updateExchange(name: String, remarks: String?, byId id: NSManagedObjectID, status: EntityStatus? = nil) -> Bool {
        do {
            let exchange = Constant.context.object(with: id) as! Exchange
            if let s = status {
                exchange.status = s.rawValue
            } else {
                if exchange.status != EntityStatus.insert.rawValue {
                    exchange.status = EntityStatus.update.rawValue
                }
            }
            exchange.name = name
            exchange.remarks = (remarks ?? "")
            try Constant.context.save()
            return true
        } catch {
            return false
        }
    }
    
    /// 删除一条数据
    static func deleteExchange(byId id: NSManagedObjectID) {
        let exchange = Constant.context.object(with: id) as! Exchange
        if exchange.status == EntityStatus.insert.rawValue {
            Constant.context.delete(exchange)
        } else {
            exchange.status = EntityStatus.delete.rawValue
        }
        
        try! Constant.context.save()
    }
    
    /// 删除一条数据
    static func deleteExchange(byId id: Int32) {
        if let result = exchange(by: id) {
            for exchange in result {
                deleteExchange(byId: exchange.objectID)
            }
        }
    }
    
    /// 更新同步标识
    static func updateExchangeStatusToSynchronized(byId id: NSManagedObjectID, delete: Bool = false) {
        let exchange = Constant.context.object(with: id) as! Exchange
        if delete {
            Constant.context.delete(exchange)
        } else {
            exchange.status = EntityStatus.synchronized.rawValue
        }
        try! Constant.context.save()
    }
}

struct MyWallet {
    /// 所有数据
    static func allWallets() -> [Wallet] {
        let request = NSFetchRequest<Wallet>(entityName: Entity.wallet)
        request.predicate = NSPredicate(format: "status != %d", EntityStatus.delete.rawValue)
        do {
            let result = try Constant.context.fetch(request)
            return result
        } catch {
            return []
        }
    }
    
    /// 所有未同步的数据
    static func allNeedSyncWallets() -> [Wallet] {
        let request = NSFetchRequest<Wallet>(entityName: Entity.wallet)
        request.predicate = NSPredicate(format: "status != %d", EntityStatus.synchronized.rawValue)
        do {
            let result = try Constant.context.fetch(request)
            return result
        } catch {
            return []
        }
    }
    
    /// 根据id查询数据
    static func wallet(by id: Int32) -> [Wallet]? {
        let request = NSFetchRequest<Wallet>(entityName: Entity.wallet)
        request.predicate = NSPredicate(format: "id == %d", id)
        do {
            let result = try Constant.context.fetch(request)
            return result
        } catch {
            return []
        }
    }
    
    /// 添加
    static func addWallet(id: Int32? = nil, name: String, remarks: String?, status: EntityStatus? = nil) -> Bool {
        do {
            let wallet = NSEntityDescription.insertNewObject(forEntityName: Entity.wallet, into: Constant.context) as! Wallet
            
            if let i = id {
                wallet.id = i
            } else {
                wallet.id = Int32(Date.timestamp())
            }
            if let s = status {
                wallet.status = s.rawValue
            } else {
                wallet.status = EntityStatus.insert.rawValue
            }
            wallet.name = name
            wallet.remarks = (remarks ?? "")
            try Constant.context.save()
            return true
        } catch {
            return false
        }
    }
    
    /// 更新
    static func updateWallet(name: String, remarks: String?, byId id: NSManagedObjectID, status: EntityStatus? = nil) -> Bool {
        do {
            let wallet = Constant.context.object(with: id) as! Wallet
            if let s = status {
                wallet.status = s.rawValue
            } else {
                if wallet.status != EntityStatus.insert.rawValue {
                    wallet.status = EntityStatus.update.rawValue
                }
            }
            wallet.name = name
            wallet.remarks = (remarks ?? "")
            try Constant.context.save()
            return true
        } catch {
            return false
        }
    }
    
    /// 删除一条数据
    static func deleteWallet(byId id: NSManagedObjectID) {
        let wallet = Constant.context.object(with: id) as! Wallet
        if wallet.status == EntityStatus.insert.rawValue {
            Constant.context.delete(wallet)
        } else {
            wallet.status = EntityStatus.delete.rawValue
        }
        try! Constant.context.save()
    }
    
    /// 删除一条数据
    static func deleteWallet(byId id: Int32) {
        if let result = wallet(by: id) {
            for wallet in result {
                deleteWallet(byId: wallet.objectID)
            }
        }
    }
    
    /// 更新同步标识
    static func updateWalletStatusToSynchronized(byId id: NSManagedObjectID, delete: Bool = false) {
        let wallet = Constant.context.object(with: id) as! Wallet
        if delete {
            Constant.context.delete(wallet)
        } else {
            wallet.status = EntityStatus.synchronized.rawValue
        }
        try! Constant.context.save()
    }
}

struct MyCollection {
    /// 所有的数据
    static func allCollections() -> [Collection] {
        let request = NSFetchRequest<Collection>(entityName: Entity.collection)
        do {
            let result = try Constant.context.fetch(request)
            return result
        } catch {
            return []
        }
    }
    
    /// 所有未同步的数据
    static func allNeedSyncCollections() -> [Collection] {
        let request = NSFetchRequest<Collection>(entityName: Entity.collection)
        request.predicate = NSPredicate(format: "status != %d", EntityStatus.synchronized.rawValue)
        do {
            let result = try Constant.context.fetch(request)
            return result
        } catch {
            return []
        }
    }
    
    /// 所有可见数据
    static func visibleCollections() -> [Collection] {
        let request = NSFetchRequest<Collection>(entityName: Entity.collection)
        request.predicate = NSPredicate(format: "visible = true AND status != %d", EntityStatus.delete.rawValue)
        let sort = NSSortDescriptor(key: "sort", ascending: true)
        request.sortDescriptors = [sort]
        do {
            let result = try Constant.context.fetch(request)
            return result
        } catch {
            return []
        }
    }
    
    /// 根据id查询数据
    static func collection(by id: Int32) -> [Collection]? {
        let request = NSFetchRequest<Collection>(entityName: Entity.collection)
        request.predicate = NSPredicate(format: "id == %d", id)
        do {
            let result = try Constant.context.fetch(request)
            return result
        } catch {
            return []
        }
    }
    
    /// 所有不可见数据
    static func invisibleCollections() -> [Collection] {
        let request = NSFetchRequest<Collection>(entityName: Entity.collection)
        request.predicate = NSPredicate(format: "visible = false AND status != %d", EntityStatus.delete.rawValue)
        let sort = NSSortDescriptor(key: "sort", ascending: true)
        request.sortDescriptors = [sort]
        do {
            let result = try Constant.context.fetch(request)
            return result
        } catch {
            return []
        }
    }
    
    /// 新增
    static func addCollection(id: Int32? = nil, sort: Int16? = nil, visible: Bool? = nil, symbol: String?, name: String?, status: EntityStatus? = nil) -> (Bool, Bool) {
        do {
            let request = NSFetchRequest<Collection>(entityName: Entity.collection)
            request.predicate = NSPredicate(format: "name = %@ AND symbol = %@", name ?? "", symbol ?? "")
            let result = try Constant.context.fetch(request)
            if result.count > 0 {
                // 存在
                if let collection = result.first {
                    // 如果是已经删除的 则变更为同步过的
                    if collection.status == EntityStatus.delete.rawValue {
                        collection.status = EntityStatus.synchronized.rawValue
                        try Constant.context.save()
                        return (true, false)
                    }
                }
                return (true, true)
            } else {
                // 不存在 新增
                let collection = NSEntityDescription.insertNewObject(forEntityName: Entity.collection, into: Constant.context) as! Collection
                
                if let i = id {
                    collection.id = i
                } else {
                    collection.id = Int32(Date.timestamp())
                }
                if let s = status {
                    collection.status = s.rawValue
                } else {
                    collection.status = EntityStatus.insert.rawValue
                }
                collection.name = name                          // 名称
                collection.symbol = symbol                      // 符号
                if let s = sort {
                    collection.sort = s
                } else {
                    collection.sort = lastVisibleCollectionSort()   // 排序
                }
                if let v = visible {
                    collection.visible = v
                } else {
                    collection.visible = true
                }
                try Constant.context.save()
                return (true, false)
            }
        } catch {
            return (false, false)
        }
    }
    
    /// 排序
    static func sortCollection(id: NSManagedObjectID, toIndex: Int16) -> Bool {
        let collection = Constant.context.object(with: id) as! Collection
        var targetCollections: [Collection] = []
        
        if collection.visible {
            targetCollections = visibleCollections()
        } else {
            targetCollections = invisibleCollections()
        }
        
        if collection.sort > toIndex {
            let collections = targetCollections.filter { $0.sort >= toIndex && $0.sort < collection.sort }
            for c in collections {
                let targetCollection = Constant.context.object(with: c.objectID) as! Collection
                targetCollection.sort = targetCollection.sort + 1
                if targetCollection.status != EntityStatus.insert.rawValue {
                    targetCollection.status = EntityStatus.update.rawValue
                }
            }
        } else {
            let collections = targetCollections.filter { $0.sort > collection.sort && $0.sort <= toIndex }
            for c in collections {
                let targetCollection = Constant.context.object(with: c.objectID) as! Collection
                targetCollection.sort = targetCollection.sort - 1
                if targetCollection.status != EntityStatus.insert.rawValue {
                    targetCollection.status = EntityStatus.update.rawValue
                }
            }
        }
        
        do {
            collection.sort = toIndex
            if collection.status != EntityStatus.insert.rawValue {
                collection.status = EntityStatus.update.rawValue
            }
            try Constant.context.save()
        } catch {
            return false
        }
        return true
    }
    
    /// 更新
    static func updateCollection(sort: Int16, visible: Bool, byId id: NSManagedObjectID, status: EntityStatus? = nil) -> Bool {
        let collection = Constant.context.object(with: id) as! Collection
        do {
            if let s = status {
                collection.status = s.rawValue
            }
            collection.sort = sort
            collection.visible = visible
            try Constant.context.save()
        } catch {
            return false
        }
        return true
    }
    
    /// 更改visible属性
    static func updateCollectionVisible(id: NSManagedObjectID, status: EntityStatus? = nil) -> Bool {
        let collection = Constant.context.object(with: id) as! Collection
        do {
            updateOtherCollectionsSort(collection: collection)
            
            if collection.visible {
                collection.sort = lastInvisibleCollectionSort()
                collection.visible = false
            } else {
                collection.sort = lastVisibleCollectionSort()
                collection.visible = true
            }
            if let s = status {
                collection.status = s.rawValue
            } else {
                if collection.status != EntityStatus.insert.rawValue {
                    collection.status = EntityStatus.update.rawValue
                }
            }
            try Constant.context.save()
        } catch {
            return false
        }
        return true
    }
    
    /// 删除一条数据
    static func deleteCollection(byId id: NSManagedObjectID) {
        let collection = Constant.context.object(with: id) as! Collection
        collection.status = EntityStatus.delete.rawValue
        do {
            // 删除相关的资产记录
            let request = NSFetchRequest<Coin>(entityName: Entity.coin)
            request.predicate = NSPredicate(format: "name = %@ AND symbol = %@", collection.name ?? "", collection.symbol ?? "")
            let result = try Constant.context.fetch(request)
            for coin in result {
                if coin.status == EntityStatus.delete.rawValue {
                    break
                }
                if coin.status == EntityStatus.insert.rawValue {
                    Constant.context.delete(coin)
                } else {
                    coin.status = EntityStatus.delete.rawValue
                }
            }
        } catch {
        }
        updateOtherCollectionsSort(collection: collection)
        try! Constant.context.save()
    }
    
    /// 删除一条数据
    static func deleteCollection(byId id: Int32) {
        if let result = collection(by: id) {
            for collection in result {
                deleteCollection(byId: collection.objectID)
            }
        }
    }
    
    /// 最后一条可见数据sort值
    private static func lastVisibleCollectionSort() -> Int16 {
        let all = visibleCollections()
        if all.count > 0, let collection = all.last {
            return collection.sort + 1
        } else {
            return 1
        }
    }
    
    /// 最后一条不可见数据sort值
    private static func lastInvisibleCollectionSort() -> Int16 {
        let all = invisibleCollections()
        if all.count > 0, let collection = all.last {
            return collection.sort + 1
        } else {
            return 1
        }
    }
    
    /// 重新排序剩下的
    private static func updateOtherCollectionsSort(collection: Collection) {
        var collections: [Collection] = []
        if collection.visible {
            collections = visibleCollections().filter { $0.sort > collection.sort }
        } else {
            collections = invisibleCollections().filter { $0.sort > collection.sort }
        }
        
        for c in collections {
            let targetCollection = Constant.context.object(with: c.objectID) as! Collection
            if targetCollection.status != EntityStatus.insert.rawValue {
                targetCollection.status = EntityStatus.update.rawValue
            }
            targetCollection.sort = targetCollection.sort - 1
        }
    }
    
    /// 更新同步标识
    static func updateCollectionStatusToSynchronized(byId id: NSManagedObjectID, delete: Bool = false) {
        let collection = Constant.context.object(with: id) as! Collection
        if delete {
            Constant.context.delete(collection)
        } else {
            collection.status = EntityStatus.synchronized.rawValue
        }
        try! Constant.context.save()
    }
}

struct MyCoin {
    /// 所有的数据
    static func allCoins() -> [Coin] {
        let request = NSFetchRequest<Coin>(entityName: Entity.coin)
        do {
            let result = try Constant.context.fetch(request)
            return result
        } catch {
            return []
        }
    }
    
    /// 所有未同步的数据
    static func allNeedSyncCoins() -> [Coin] {
        let request = NSFetchRequest<Coin>(entityName: Entity.coin)
        request.predicate = NSPredicate(format: "status != %d", EntityStatus.synchronized.rawValue)
        do {
            let result = try Constant.context.fetch(request)
            return result
        } catch {
            return []
        }
    }
    
    /// 根据id查询数据
    static func coin(by id: Int32) -> [Coin]? {
        let request = NSFetchRequest<Coin>(entityName: Entity.coin)
        request.predicate = NSPredicate(format: "id == %d", id)
        do {
            let result = try Constant.context.fetch(request)
            return result
        } catch {
            return []
        }
    }
    
    /// 添加
    static func addCoin(id: Int32? = nil, name: String?, symbol: String?, num: Double, priceIsTotal: Bool, price: Double, currency: String?, resideIsWallet: Bool, reside: String?, buyDate: String?, remarks: String?, status: EntityStatus? = nil) -> Bool {
        do {
            let coin = NSEntityDescription.insertNewObject(forEntityName: Entity.coin, into: Constant.context) as! Coin
            
            if let i = id {
                coin.id = i
            } else {
                coin.id = Int32(Date.timestamp())
            }
            if let s = status {
                coin.status = s.rawValue
            } else {
                coin.status = EntityStatus.insert.rawValue
            }
            coin.name = name                        // 名称
            coin.symbol = symbol                    // 符号
            coin.num = num                          // 数量
            coin.priceIsTotal = priceIsTotal        // 单价or总价 默认单价
            coin.price = price                      // 单价or总价
            let `currency` = (price > 0.00 ? currency : "")
            coin.currency = `currency`              // 货币符号
            coin.resideIsWallet = resideIsWallet    // 钱包or市场 默认市场
            coin.reside = reside                    // 钱包or市场名称
            coin.buyDate = buyDate                  // 购买日期
            coin.remarks = remarks                  // 备注
            
            // 添加关注
            let _ = MyCollection.addCollection(symbol: symbol, name: name)
            try Constant.context.save()
            return true
        } catch {
            return false
        }
    }
    
    /// 更新
    static func updateCoin(id: NSManagedObjectID, name: String?, symbol: String?, num: Double, priceIsTotal: Bool, price: Double, currency: String?, resideIsWallet: Bool, reside: String?, buyDate: String?, remarks: String?, status: EntityStatus? = nil) -> Bool {
        do {
            let coin = Constant.context.object(with: id) as! Coin
            if let s = status {
                coin.status = s.rawValue
            } else {
                if coin.status != EntityStatus.insert.rawValue {
                    coin.status = EntityStatus.update.rawValue
                }
            }
            coin.name = name                        // 名称
            coin.symbol = symbol                    // 符号
            coin.num = num                          // 数量
            coin.priceIsTotal = priceIsTotal        // 单价or总价 默认单价
            coin.price = price                      // 单价or总价
            let `currency` = (price > 0.00 ? currency : "")
            coin.currency = `currency`              // 货币符号
            coin.resideIsWallet = resideIsWallet    // 钱包or市场 默认市场
            coin.reside = reside                    // 钱包or市场名称
            coin.buyDate = buyDate                  // 购买日期
            coin.remarks = remarks                  // 备注
            try Constant.context.save()
            return true
        } catch {
            return false
        }
    }
    
    /// 更新数量
    static func updateCoin(id: NSManagedObjectID, num: Double) -> Bool {
        do {
            let coin = Constant.context.object(with: id) as! Coin
            if coin.status != EntityStatus.insert.rawValue {
                coin.status = EntityStatus.update.rawValue
            }
            coin.num = num
            try Constant.context.save()
            return true
        } catch {
            return false
        }
    }
    
    /// 删除一条数据
    static func deleteCoin(byId id: NSManagedObjectID) {
        let coin = Constant.context.object(with: id) as! Coin
        if coin.status == EntityStatus.insert.rawValue {
            Constant.context.delete(coin)
        } else {
            coin.status = EntityStatus.delete.rawValue
        }
        
        try! Constant.context.save()
    }
    
    /// 删除一条数据
    static func deleteCoin(byId id: Int32) {
        if let result = coin(by: id) {
            for coin in result {
                deleteCoin(byId: coin.objectID)
            }
        }
    }
    
    /// 更新同步标识
    static func updateCoinStatusToSynchronized(byId id: NSManagedObjectID, delete: Bool = false) {
        let coin = Constant.context.object(with: id) as! Coin
        if delete {
            Constant.context.delete(coin)
        } else {
            coin.status = EntityStatus.synchronized.rawValue
        }
        try! Constant.context.save()
    }
}

struct MyPriceCache {
    /// 添加一条缓存记录
    static func addPriceCache(with symbol: String, name: String, price: Double, priceUSD: Double, currency: String, percent1h: Double, percent24h: Double, percent7d: Double) {
        do {
            let priceCache = NSEntityDescription.insertNewObject(forEntityName: Entity.priceCache, into: Constant.context) as! PriceCache
            priceCache.symbol = symbol
            priceCache.name = name
            priceCache.price = price
            priceCache.priceUSD = priceUSD
            priceCache.currency = currency
            priceCache.percent1h = percent1h
            priceCache.percent24h = percent24h
            priceCache.percent7d = percent7d
            try Constant.context.save()
        } catch {
        }
    }
    
    static func priceCache(by symbol: String, name: String, currency: String) -> (price: Double, priceUSD: Double, percent1h: Double, percent24h: Double, percent7d: Double)? {
        let request = NSFetchRequest<PriceCache>(entityName: Entity.priceCache)
        request.predicate = NSPredicate(format: "symbol = %@ AND name = %@ AND currency = %@", symbol, name, currency)
        do {
            let result = try Constant.context.fetch(request)
            if result.count > 0, let p = result.last {
                return (p.price, p.priceUSD, p.percent1h, p.percent24h, p.percent7d)
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}
