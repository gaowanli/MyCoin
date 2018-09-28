//
//  MessageItemCell.swift
//  MyCoin
//
//  Created by GaoWanli on 17/01/2018.
//  Copyright © 2018 wl. All rights reserved.
//

import UIKit
import LeanCloud

class MessageItemCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    var message: LCObject? {
        didSet {
            if let m = message {
                let cn = (Language.current == .chinese)
                let titleCN = m.get(MessageClass.title.column)?.stringValue ?? ""
                let titleEN = m.get(MessageClass.titleEN.column)?.stringValue ?? ""
                let title = (cn ? titleCN : titleEN)
                
                titleLabel.text = title
                if let date = m.get(MessageClass.timestamp.column)?.doubleValue {
                    dateLabel.text = date.dateString()
                } else {
                    dateLabel.text = nil
                }
            } else {
                titleLabel.text = nil
                dateLabel.text = nil
            }
        }
    }
}
