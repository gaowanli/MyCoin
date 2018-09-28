//
//  PriceInputCell.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/5.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

private struct LocalizedKey {
    static let placeholder = "Placeholder"
    static let unitPrice = "UnitPrice"
    static let totalPrice = "TotalPrice"
}

class PriceInputCell: UITableViewCell {
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var errorView: UIView!
    @IBOutlet private weak var currencyLabel: UILabel!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
    var price: Double = 0.00 {
        didSet {
            if price == 0.00 {
                textField.text = ""
            } else {
                textField.text = price.trueDecimalString() ?? "0.00"
            }
        }
    }
    var currency: String = "" {
        didSet {
            currencyLabel.text = currency
        }
    }
    var isTotalPrice: Bool = false {
        didSet {
            segmentedControl.selectedSegmentIndex = (isTotalPrice ? 1 : 0)
        }
    }
    var error: Bool = false {
        didSet {
            errorView.isHidden = !error
        }
    }
    var didChangeInputValue: ((String?) -> ())?
    var didChangeSegmentedControlSelected: ((Bool) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.placeholder = localizedString(with: LocalizedKey.placeholder)
        segmentedControl.setTitle(localizedString(with: LocalizedKey.unitPrice), forSegmentAt: 0)
        segmentedControl.setTitle(localizedString(with: LocalizedKey.totalPrice), forSegmentAt: 1)
        NotificationCenter.default.addObserver(self, selector: #selector(inputTextFieldTextDidChange(notif:)), name: .textFieldTextDidChange, object: textField)
    }
    
    @IBAction func segmentedControlValueChanged() {
        didChangeSegmentedControlSelected?(segmentedControl.selectedSegmentIndex == 1)
    }
    
    @objc private func inputTextFieldTextDidChange(notif: Notification) {
        didChangeInputValue?(textField.text)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("deinit \(type(of: self))")
    }
}
