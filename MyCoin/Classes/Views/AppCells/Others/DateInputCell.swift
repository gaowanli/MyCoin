//
//  DateInputCell.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/5.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

class DateInputCell: UITableViewCell {
    @IBOutlet private weak var dayTextField: TextField!
    @IBOutlet private weak var monthTextField: TextField!
    @IBOutlet private weak var yearTextField: TextField!
    @IBOutlet private weak var errorView: UIView!
    
    var dateString: String = "" {
        didSet {
            let str = dateString.components(separatedBy: ".")
            if str.count == 3 {
                yearTextField.text = str[0]
                monthTextField.text = str[1]
                dayTextField.text = str[2]
            } else {
                yearTextField.text = ""
                monthTextField.text = ""
                dayTextField.text = ""
            }
        }
    }
    var error: Bool = false {
        didSet {
            errorView.isHidden = !error
        }
    }
    var didChangeInputValue: ((String, String, String) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(inputTextFieldTextDidChange(notif:)), name: .textFieldTextDidChange, object: dayTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(inputTextFieldTextDidChange(notif:)), name: .textFieldTextDidChange, object: monthTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(inputTextFieldTextDidChange(notif:)), name: .textFieldTextDidChange, object: yearTextField)
    }
    
    @objc private func inputTextFieldTextDidChange(notif: Notification) {
        let textField = notif.object as! UITextField
        
        if textField == yearTextField, let y = textField.text, y.count >= 4 {
            let sIndex = y.startIndex
            let eIndex = y.index(sIndex, offsetBy: 4)
            yearTextField.text = String(y[sIndex..<eIndex])
            monthTextField.becomeFirstResponder()
        } else if textField == monthTextField, let m = textField.text {
            if m.count >= 2 {
                let sIndex = m.startIndex
                let eIndex = m.index(sIndex, offsetBy: 2)
                monthTextField.text = String(m[sIndex..<eIndex])
                dayTextField.becomeFirstResponder()
            }
        } else if textField == dayTextField, let d = textField.text, d.count >= 2 {
            let sIndex = d.startIndex
            let eIndex = d.index(sIndex, offsetBy: 2)
            dayTextField.text = String(d[sIndex..<eIndex])
            dayTextField.resignFirstResponder()
        }
        
        didChangeInputValue?(yearTextField.text ?? "", monthTextField.text ?? "", dayTextField.text ?? "")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("deinit \(type(of: self))")
    }
}
