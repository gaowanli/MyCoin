//
//  CoinTagCell.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/5.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

class CoinTagCell: UITableViewCell {
    @IBOutlet private weak var tagLabel: UILabel!
    @IBOutlet private weak var errorView: UIView!
    
    var tagText: String = "" {
        didSet {
            if tagText.isEmpty {
                tagLabel.textColor = .lightGray
                tagLabel.text = commonLocalizedString(with: CommonLocalizedKey.search)
            } else {
                tagLabel.textColor = .black
                tagLabel.text = tagText
            }
        }
    }
    var error: Bool = false {
        didSet {
            errorView.isHidden = !error
        }
    }
}
