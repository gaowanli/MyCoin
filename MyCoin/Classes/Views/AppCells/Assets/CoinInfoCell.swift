//
//  CoinInfoCell.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/10/30.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

class CoinInfoCell: UITableViewCell {
    @IBOutlet private weak var symbolLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var arrowImageView: UIImageView!
    
    var info: NSDictionary? {
        didSet {
            if let name = info?["name"] {
                nameLabel.text = (name as? String)
            } else {
                nameLabel.text = ""
            }
            
            if let symbol = info?["symbol"] {
                symbolLabel.text = (symbol as? String)
            } else {
                symbolLabel.text = ""
            }
        }
    }
    var collection: Collection? {
        didSet {
            if let name = collection?.name {
                nameLabel.text = name
            } else {
                nameLabel.text = ""
            }
            
            if let symbol = collection?.symbol {
                symbolLabel.text = symbol
            } else {
                symbolLabel.text = ""
            }
        }
    }
    var accessory: Bool = true {
        didSet {
            arrowImageView.isHidden = !accessory
        }
    }
}
