//
//  AnalysisManager.swift
//  MyCoin
//
//  Created by GaoWanli on 19/01/2018.
//  Copyright © 2018 wl. All rights reserved.
//

import Foundation

struct AnalysisManager {
    static var logText = ""
    
    static func analysis(completion: ((String?) -> ())?) {
        analysisConifugre {
            analysisCoreData {
                analysisFetchPrice {
                    writeTxtFile(completion: { (file) in
                        completion?(file)
                    })
                }
            }
        }
    }
    
    private static func analysisConifugre(completion: (() -> ())?) {
        logText = logText + "====================configure====================\n\n\n"
        logText = logText + configureString() + "\n"
        completion?()
    }

    private static func analysisCoreData(completion: (() -> ())?) {
        let allCollections = MyCollection.allCollections()
        logText = logText + "\n\n====================collection====================\n\n\n"
        for collection in allCollections {
            let name = collection.name ?? ""
            let symbol = collection.symbol ?? ""
            logText = logText + name + "  " + symbol + "\n"
        }
        
        let allCoins = MyCoin.allCoins()
        logText = logText + "\n\n====================coin====================" + "\n\n\n"
        for coin in allCoins {
            let name = coin.name ?? ""
            let symbol = coin.symbol ?? ""
            let num = coin.num
            logText = logText + name + "  " + symbol  + "  " + "\(num)" + "\n"
        }
        
        completion?()
    }
    
    private static func analysisFetchPrice(completion: (() -> ())?) {
        let allCollections = MyCollection.allCollections()
        let num = allCollections.count
        let currency = UserDefaults.Settings.stringValue(.currency)
        
        let group = DispatchGroup()
        logText = logText + "\n\n====================network====================\n\n\n"
        for i in 0..<num {
            let coin = allCollections[i]
            let name = coin.name ?? ""
            
            group.enter()
            fetchPrice(name: name, currency: currency, completion: { (log) in
                logText = logText + log
                group.leave()
            })
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion?()
        }
    }
    
    private static func fetchPrice(name: String, currency: String, completion: ((String) -> ())?) {
        let url = Api.tickerUrl + "\(name)/?convert=\(currency)"
        
        var log = ""
        NetworkManager.share.requestJSON(url: url, method: .get, parameters: nil) { (data, success, error) in
            if success {
                if let array = data as? [[String: String]], array.count > 0 {
                    let dict = array[0]
                    log = log + name + " fetchPrice success #1:\n" + dict.description + "\n\n"
                    let price = CoinPrice(with: dict)
                    log = log + name + " transform success #2:\n" + coinPriceDescription(price: price) + "\n\n"
                    if let error = dict["error"], !error.isEmpty {
                        log = log + name + " data error #1" + "\n"
                    }
                } else {
                    if let array = data as? [Any], array.count > 0 {
                        if let dict = array[0] as? [String: Any] {
                            log = log + name + " fetchPrice success #2:\n" + dict.description + "\n\n"
                            let price = CoinPrice(with: dict)
                            log = log + name + " transform success #2:\n" + coinPriceDescription(price: price) + "\n\n"
                        } else {
                            log = log + name + " data error #2" + "\n"
                        }
                    } else {
                        log = log + name + " data error #3" + "\n"
                    }
                }
            } else {
                log = log + name + " fetchPrice error:" + (error ?? "") + "\n"
            }
            completion?(log)
        }
    }
    
    private static func coinPriceDescription(price: CoinPrice?) -> String {
        var desc = ""
        if let p = price {
            desc = p.name + " " + p.symbol + " " + "\(p.price)" + " " + "\(p.priceUSD)" + " " + "\(p.percent1h)" + " " + "\(p.percent24h)" + " " + "\(p.percent7d)" + " " + "\(p.marketCap)"
        }
        return desc
    }
    
    private static func writeTxtFile(completion: ((String?) -> ())?) {
        if let directory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            let file = directory + "/log.txt"
            do {
                try logText.write(toFile: file, atomically: true, encoding: String.Encoding.utf8)
                completion?(file)
            } catch {
                completion?(nil)
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
