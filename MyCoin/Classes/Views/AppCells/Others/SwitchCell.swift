//
//  SwitchCell.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/10/30.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var switchControl: UISwitch!
    @IBOutlet private weak var titleLabelToSuperLeft: NSLayoutConstraint!
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    var switchOn: Bool = false {
        didSet {
            switchControl.isOn = switchOn
        }
    }
    var didChangeSwitchOn: ((Bool) -> ())?
    
    @IBAction func switchValueChanged() {
        didChangeSwitchOn?(switchControl.isOn)
    }
}
