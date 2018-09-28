//
//  BuyRecordCell.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/26.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

private struct LocalizedKey {
    static let buyDate = "BuyDate" 
}

class BuyRecordCell: UITableViewCell {
    @IBOutlet private weak var descLabel: UILabel!      // 存放地址、数量、买入价格
    @IBOutlet private weak var buyDateLabel: UILabel!   // 买入日期
    @IBOutlet private weak var remarksLabel: UILabel!
    @IBOutlet private weak var subButton: UIButton!
    @IBOutlet private var separatorLabelHeights: [NSLayoutConstraint]!
    @IBOutlet private weak var buyDateViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var remarksViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var viewToBottom: NSLayoutConstraint!
    
    var isLastRow: Bool = false {
        didSet {
            viewToBottom.constant = (isLastRow ? 10.0 : 0.0)
        }
    }
    var didClickSubButton: ((Coin?) -> ())?
    var didClickDeleteButton: ((Coin?) -> ())?
    var coin: Coin? {
        didSet {
            let totalPrice = ((coin?.price ?? 0.00).trueDecimalString() ?? "0.00")
            var totalPriceStr = ""
            if totalPrice != "0.00" {
                if let priceIsTotal = coin?.priceIsTotal, true == priceIsTotal {
                    totalPriceStr = commonLocalizedString(with: CommonLocalizedKey.totalPrice)
                } else {
                    totalPriceStr = commonLocalizedString(with: CommonLocalizedKey.unitPrice)
                }
            }
            
            var reside = coin?.reside ?? ""
            reside = (reside.isEmpty ? reside : "\(reside) × ")
            let num = coin?.num ?? 0.00
            let numStr = num.trueDecimalString() ?? "0.00"
            
            if totalPriceStr.isEmpty {
                descLabel.text = "\(reside)\(numStr)"
            } else {
                descLabel.text = "\(reside)\(numStr) \(totalPriceStr):\(coinCurrencyIcon())\(totalPrice)"
            }
            if let buyDate = coin?.buyDate, !buyDate.isEmpty {
                let title = localizedString(with: LocalizedKey.buyDate)
                buyDateLabel.text = title + ":\(buyDate)"
                buyDateViewHeight.constant = 33.0
            } else {
                buyDateLabel.text = ""
                buyDateViewHeight.constant = 0.0
            }
            if let remarks = coin?.remarks, !remarks.isEmpty {
                remarksLabel.text = remarks
            } else {
                remarksLabel.text = ""
            }
            
            if let remarks = coin?.remarks, !remarks.isEmpty {
                let maxWidth = Constant.screenWidth - 44.0
                let height = remarks.height(byFont: remarksLabel.font, andMaxWidth: maxWidth)
                remarksViewHeight.constant = height + 18.5
            } else {
                remarksViewHeight.constant = 0.0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if UIScreen.main.scale == 3.0 {
            _ = separatorLabelHeights.map({ $0.constant = 0.33 })
        }
    }
}

// MARK:- Methods
extension BuyRecordCell {
    private func coinCurrencyIcon() -> String {
        var symbolIcon = ""
        if let currency = coin?.currency {
            let currencyStr = currency.lowercased()
            
            if let symbol = CurrencySymbol(rawValue: currencyStr) {
                symbolIcon = CurrencySymbol.icon(symbol: symbol)
            }
        }
        return symbolIcon
    }
}

// MARK:- Events
extension BuyRecordCell {
    @IBAction func subButtonPressed() {
        didClickSubButton?(coin)
    }
    
    @IBAction func deleteButtonPressed() {
        didClickDeleteButton?(coin)
    }
}
