//
//  TextViewCell.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/6.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

class TextViewCell: UITableViewCell {
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var errorView: UIView!
    
    var value: String? = "" {
        didSet {
            textView.text = value
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(inputTextViewTextDidChange(notif:)), name: .textViewTextDidChange, object: textView)
    }
    
    @objc private func inputTextViewTextDidChange(notif: Notification) {
        didChangeInputValue?(textView.text)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("deinit \(type(of: self))")
    }
}
