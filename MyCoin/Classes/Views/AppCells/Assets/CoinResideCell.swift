//
//  CoinResideCell.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/6.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

class CoinResideCell: UITableViewCell {
    @IBOutlet private weak var tagLabel: UILabel!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
    var tagText: String = "" {
        didSet {
            if tagText.isEmpty {
                tagLabel.textColor = .lightGray
                tagLabel.text = commonLocalizedString(with: CommonLocalizedKey.select)
            } else {
                tagLabel.textColor = .black
                tagLabel.text = tagText
            }
        }
    }
    var isWallet: Bool = false {
        didSet {
            segmentedControl.selectedSegmentIndex = (isWallet ? 1 : 0)
        }
    }
    var didChangeSegmentedControlSelected: ((Bool) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        segmentedControl.setTitle(commonLocalizedString(with: CommonLocalizedKey.exchange), forSegmentAt: 0)
        segmentedControl.setTitle(commonLocalizedString(with: CommonLocalizedKey.wallet), forSegmentAt: 1)
    }
    
    @IBAction func segmentedControlValueChanged() {
        didChangeSegmentedControlSelected?(segmentedControl.selectedSegmentIndex == 1)
    }
}
