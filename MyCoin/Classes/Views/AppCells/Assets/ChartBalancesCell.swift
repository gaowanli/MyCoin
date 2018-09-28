//
//  ChartBalancesCell.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/12/22.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

class ChartBalancesCell: UITableViewCell {
    @IBOutlet private weak var colorView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descLabel: UILabel!
    
    var color: UIColor? = nil {
        didSet {
            colorView.backgroundColor = color
        }
    }
    var content: String = "" {
        didSet {
            let s = content.components(separatedBy: "|")
            
            if s.count == 2 {
                titleLabel.text = s[0]
                descLabel.text = s[1]
            } else {
                titleLabel.text = content
                descLabel.text = ""
            }
        }
    }
}
