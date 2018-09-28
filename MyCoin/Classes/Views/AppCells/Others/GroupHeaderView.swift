//
//  GroupHeaderView.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/1.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

class GroupHeaderView: UITableViewHeaderFooterView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descLabel: UILabel!
    
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
}
