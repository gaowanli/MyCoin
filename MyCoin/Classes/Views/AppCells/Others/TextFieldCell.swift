//
//  TextFieldCell.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/5.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var errorView: UIView!
    @IBOutlet private weak var textFieldWidth: NSLayoutConstraint!
    
    var placeholder: String = "" {
        didSet {
            textField.placeholder = placeholder
        }
    }
    var inputString: Bool = false {
        didSet {
            textField.keyboardType = (inputString ? .default : .decimalPad)
        }
    }
    var textFieldNeedLong: Bool = false {
        didSet {
            textFieldWidth.constant = (textFieldNeedLong ? 160.0 : 100.0)
        }
    }
    var stringValue: String? = "" {
        didSet {
            if false == inputString, let s = stringValue, s.decimalValue() == 0.00 {
                textField.text = ""
            } else {
                textField.text = stringValue
            }
        }
    }
    var error: Bool = false {
        didSet {
            errorView.isHidden = !error
        }
    }
    var didChangeInputValue: ((String?) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(inputTextFieldTextDidChange(notif:)), name: .textFieldTextDidChange, object: textField)
    }
    
    @objc private func inputTextFieldTextDidChange(notif: Notification) {
        didChangeInputValue?(textField.text)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("deinit \(type(of: self))")
    }
}
