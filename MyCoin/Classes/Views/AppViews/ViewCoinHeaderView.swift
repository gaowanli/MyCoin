//
//  ViewCoinHeaderView.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/26.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

private struct LocalizedKey {
    static let nowPrice = "NowPrice"
    static let marketCap = "MarketCap"
    static let updateTime = "UpdateTime"
}

class ViewCoinHeaderView: UITableViewHeaderFooterView {
    @IBOutlet private weak var symbolLabel: UILabel!        // 符号
    @IBOutlet private weak var linkButton: UIButton!        // 链接
    @IBOutlet private weak var rankButton: UIButton!        // 市值排行
    @IBOutlet private weak var nameLabel: UILabel!          // 名称
    @IBOutlet private weak var nowPriceLabel: UILabel!      // 当前价格
    @IBOutlet private weak var marketCapLabel: UILabel!     // 市值
    @IBOutlet private weak var oneHourPercentLabel: UILabel!
    @IBOutlet private weak var twentyFourHourPercentLabel: UILabel!
    @IBOutlet private weak var sevenDayPercentLabel: UILabel!
    @IBOutlet private weak var updateTimeLabel: UILabel!
    @IBOutlet private var separatorLabelHeights: [NSLayoutConstraint]!
    
    var data: (coin: CollectionCoin?, price: CoinPrice?) {
        didSet {
            reloadData()
        }
    }
    var currencySymbol: String = ""
    var didClickLinkButton: ((String?) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        if UIScreen.main.scale == 3.0 {
            _ = separatorLabelHeights.map({ $0.constant = 0.33 })
        }
    }
    
    private func reloadData() {
        var symbol = data.price?.symbol ?? ""
        var name = data.price?.name ?? ""
        if symbol.isEmpty, name.isEmpty {
            symbol = data.coin?.symbol ?? ""
            name = data.coin?.name ?? ""
        }
        symbolLabel.text = symbol
        nameLabel.text = name
        
        var pUSD = ""
        let usdPrice = UserDefaults.Settings.boolValue(.usdPrice)
        if usdPrice, let p = data.price?.priceUSD {
            pUSD = "  $\(p.decimalString() ?? "0.00")"
        }
        let p = data.price?.price ?? 0.00
        nowPriceLabel.text = localizedString(with: LocalizedKey.nowPrice) + ":\(currencySymbol)\(p.decimalString() ?? "0.00")" + pUSD
        
        let marketCap = data.price?.marketCap ?? 0.00
        marketCapLabel.text = localizedString(with: LocalizedKey.marketCap) + ":\(currencySymbol)\(marketCap.decimalString() ?? "0.00")"
        
        let rank = data.price?.rank ?? 0
        rankButton.isHidden = (rank <= 0)
        rankButton.setTitle("  No.\(rank)  ", for: .normal)
        
        var oneHourPercent = data.price?.percent1h ?? 0.00
        var flag = "+"
        if oneHourPercent < 0.00 {
            flag = "-"
        }
        setPercentLabelColor(label: oneHourPercentLabel, percent: oneHourPercent)
        oneHourPercent = abs(oneHourPercent)
        if let o = oneHourPercent.decimalString() {
            oneHourPercentLabel.text = "\(flag)\(o)%"
        } else {
            oneHourPercentLabel.text = "\(flag)0.00%"
        }
        
        var twentyFourHourPercent = data.price?.percent24h ?? 0.00
        flag = "+"
        if twentyFourHourPercent < 0.00 {
            flag = "-"
        }
        setPercentLabelColor(label: twentyFourHourPercentLabel, percent: twentyFourHourPercent)
        twentyFourHourPercent = abs(twentyFourHourPercent)
        if let t = twentyFourHourPercent.decimalString() {
            twentyFourHourPercentLabel.text = "\(flag)\(t)%"
        } else {
            twentyFourHourPercentLabel.text = "\(flag)0.00%)"
        }
        
        var sevenDayPercent = data.price?.percent7d ?? 0.00
        flag = "+"
        if sevenDayPercent < 0.00 {
            flag = "-"
        }
        setPercentLabelColor(label: sevenDayPercentLabel, percent: sevenDayPercent)
        sevenDayPercent = abs(sevenDayPercent)
        if let s = sevenDayPercent.decimalString() {
            sevenDayPercentLabel.text = "\(flag)\(s)%"
        } else {
            sevenDayPercentLabel.text = "\(flag)0.00%)"
        }
        
        if let date = data.price?.updatedTime {
            updateTimeLabel.text = localizedString(with: LocalizedKey.updateTime) + ":\(date.dateString())"
        }
    }
    
    private func setPercentLabelColor(label: UILabel, percent: Double) {
        let marketRedColor = UserDefaults.Settings.boolValue(.marketColor) // 涨幅颜色
        if percent >= 0.00 {
            let color: UIColor = (marketRedColor ? .redColor : .greenColor)
            label.textColor = color
        } else {
            let color: UIColor = (marketRedColor ? .greenColor : .redColor)
            label.textColor = color
        }
    }
}

// MARK:- Events
extension ViewCoinHeaderView {
    @IBAction func linkButtonPressed() {
        didClickLinkButton?(data.coin?.name)
    }
}
