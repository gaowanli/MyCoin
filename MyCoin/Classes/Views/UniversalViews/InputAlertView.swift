//
//  InputAlertView.swift
//  MyCoin
//
//  Created by GaoWanli on 10/01/2018.
//  Copyright © 2018 wl. All rights reserved.
//

import UIKit

class InputAlertView: UIView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var confirmButton: UIButton!
    
    private var isInputNumber: Bool = false
    private var maxNumber: Double = 0.0
    private lazy var generator: UIImpactFeedbackGenerator = {
        let g = UIImpactFeedbackGenerator(style: .medium)
        g.prepare()
        return g
    }()
    
    var didValidNumber: ((Double) -> ())?
    var didValidString: ((String) -> ())?
    
    static func view() -> InputAlertView {
        return (Bundle.main.loadNibNamed("InputAlertView", owner: self, options: nil)?.last) as! InputAlertView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setCommonLocalizedString(with: cancelButton, key: CommonLocalizedKey.cancel)
        setCommonLocalizedString(with: confirmButton, key: CommonLocalizedKey.confirm)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        textField.becomeFirstResponder()
    }
    
    func show(with title: String, message: String, number: Double) {
        titleLabel.text = title
        messageLabel.text = message
        maxNumber = number
        isInputNumber = true
        textField.keyboardType = .decimalPad
        
        show()
    }
    
    func show(with title: String, message: String, text: String) {
        titleLabel.text = title
        messageLabel.text = message
        textField.text = text
        
        show()
    }
    
    func dismiss() {
        endEditing(true)
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView.alpha = 0.5
            self.alpha = 0.0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    private func show() {
        mainThread {
            self.frame = UIScreen.main.bounds
            let window = UIApplication.shared.keyWindow
            window?.addSubview(self)
            
            self.contentView.alpha = 0.5
            self.alpha = 0.0
            UIView.animate(withDuration: 0.3, animations: {
                self.contentView.alpha = 1.0
                self.alpha = 1.0
            })
        }
    }
    
    private func confirm() {
        guard let text = textField.text else {
            return
        }
        
        if true == isInputNumber {
            if let number = Double(text), number.isDecimal(), number >= Constant.minNumber, number <= maxNumber {
                dismiss()
                didValidNumber?(number)
            } else {
                showError()
            }
        } else {
            if text.trimWhitespaces().count > 0 {
                dismiss()
                didValidString?(text)
            } else {
                showError()
            }
        }
    }
    
    private func showError() {
        contentView.shake()
        generator.impactOccurred()
    }
}

// MARK:- Events
extension InputAlertView {
    @IBAction func buttonPressed(_ button: UIButton) {
        if confirmButton == button {
            confirm()
        } else {
            dismiss()
        }
    }
}

// MARK:- UITextFieldDelegate
extension InputAlertView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        confirm()
        return true
    }
}
