//
//  ItemCell.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/10/30.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descLabel: UILabel!
    @IBOutlet private weak var arrowImageView: UIImageView!
    
    var title: String = "" {
        didSet {
            let s = title.components(separatedBy: "|")
            
            if s.count > 1 {
                titleLabel.text = s[0]
                descLabel.text = s[1]
            } else {
                titleLabel.text = title
                descLabel.text = ""
            }
        }
    }
    var accessory: Bool = true {
        didSet {
            arrowImageView.isHidden = !accessory
        }
    }
    var accessoryIsArrow: Bool = true {
        didSet {
            let arrow = #imageLiteral(resourceName: "icon_enter")
            let selected = #imageLiteral(resourceName: "icon_selected")
            arrowImageView.image = (accessoryIsArrow ? arrow : selected)
        }
    }
}
