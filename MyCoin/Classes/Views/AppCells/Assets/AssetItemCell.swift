//
//  AssetItemCell.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/19.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

class AssetItemCell: UITableViewCell {
    @IBOutlet private weak var percentIconLabel: UILabel!   // 涨跌百分比指示器
    @IBOutlet private weak var symbolLabel: UILabel!        // 符号
    @IBOutlet private weak var percentLabel: UILabel!       // 涨跌百分比
    @IBOutlet private weak var priceLabel: UILabel!         // 价格
    @IBOutlet private weak var usdPriceLabel: UILabel!      // 美元价格
    @IBOutlet private weak var assetsView: UIStackView!
    @IBOutlet private weak var numberLabel: UILabel!        // 数量
    @IBOutlet private weak var totalPriceLabel: UILabel!    // 总价
    
    var coin: CollectionCoin? {
        didSet {
            symbolLabel.text = coin?.symbol
            if let num = coin?.num, num > 0.00 {
                assetsView.isHidden = false
                numberLabel.text = num.numDecimalString() ?? "0.00"
            } else {
                assetsView.isHidden = true
            }
            displayPriceInfo()
        }
    }
    var defalutData: NSDictionary? {
        didSet {
            assetsView.isHidden = true
            if let dict = defalutData {
                symbolLabel.text = (dict["symbol"] as? String) ?? ""
            }
        }
    }
    var price: CoinPrice? {
        didSet {
            displayPriceInfo()
        }
    }
    var currencySymbol: String = ""
    
    private func displayPriceInfo() {
        let percentChange = UserDefaults.Settings.stringValue(.percentChange) // 涨跌周期
    
        if let p = price {
            // 涨跌百分比
            var percent = 0.00
            switch PercentChange(rawValue: percentChange)! {
            case .oneHour:
                percent = p.percent1h
            case .twentyFourHour:
                percent = p.percent24h
            case .sevenDay:
                percent = p.percent7d
            }
            displayPriceInfo(price: p.price, usdPrice: p.priceUSD, percent: percent)
        } else if let cache = coin?.cachePrice {
            // 涨跌百分比
            var percent = 0.00
            switch PercentChange(rawValue: percentChange)! {
            case .oneHour:
                percent = cache.percent1h
            case .twentyFourHour:
                percent = cache.percent24h
            case .sevenDay:
                percent = cache.percent7d
            }
            displayPriceInfo(price: cache.price, usdPrice: cache.priceUSD, percent: percent)
        } else {
            percentLabel.text = "+0.00%"
            totalPriceLabel.text = "\(currencySymbol)0.00"
            priceLabel.text = "\(currencySymbol)0.00"
            
            let usdPrice = UserDefaults.Settings.boolValue(.usdPrice)
            if usdPrice {
                usdPriceLabel.text = "$0.00"
            } else {
                usdPriceLabel.text = ""
            }
        }
    }
    
    private func displayPriceInfo(price: Double, usdPrice: Double, percent: Double) {
        let marketRedColor = UserDefaults.Settings.boolValue(.marketColor) // 涨幅颜色
        
        // 当前价格
        var priceStr = "0.00"
        if price < 1.0 {
            priceStr = String(format: "%.6f", price)
        } else if price >= 1.0 {
            priceStr = String(format: "%.2f", price)
        }
        priceLabel.text = "\(currencySymbol)\(priceStr)"
        
        let u = UserDefaults.Settings.boolValue(.usdPrice)
        let currency = UserDefaults.Settings.stringValue(.currency).lowercased()
        if u, currency != "usd" {
            // 美元价格
            var usdPriceStr = "0.00"
            if usdPrice < 1.0 {
                usdPriceStr = String(format: "%.6f", usdPrice)
            } else if usdPrice >= 1.0 {
                usdPriceStr = String(format: "%.2f", usdPrice)
            }
            usdPriceLabel.text = "$\(usdPriceStr)"
        } else {
            usdPriceLabel.text = ""
        }
        
        var flag = "+"
        if percent < 0.00 {
            flag = "-"
        }
        let percentStr = String(format: "%.2f", abs(percent))
        percentLabel.text = "\(flag)\(percentStr)%"
        if percent >= 0.0 {
            let color: UIColor = (marketRedColor ? .redColor : .greenColor)
            percentIconLabel.backgroundColor = color
            percentLabel.textColor = color
        } else {
            let color: UIColor = (marketRedColor ? .greenColor : .redColor)
            percentIconLabel.backgroundColor = color
            percentLabel.textColor = color
        }
        
        var totalPrice = 0.00 // 总价
        if let num = coin?.num, num > 0.00 {
            totalPrice = price * num
        }
        let totalPriceStr = (totalPrice.decimalString() ?? "0.00")
        totalPriceLabel.text = "\(currencySymbol)\(totalPriceStr)"
    }
}
