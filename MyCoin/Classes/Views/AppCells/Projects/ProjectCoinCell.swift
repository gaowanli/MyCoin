//
//  ProjectCoinCell.swift
//  MyCoin
//
//  Created by GaoWanli on 22/02/2018.
//  Copyright © 2018 wl. All rights reserved.
//

import UIKit

private struct LocalizedKey {
    static let inNumPlaceholder = "InNumPlaceholder"
    static let outNumPlaceholder = "OutNumPlaceholder"
    static let outTokenPlaceholder = "OutTokenPlaceholder"
}

protocol ProjectCoinCellDelegate: NSObjectProtocol {
    func projectCoinCell(_ projectCoinCell: ProjectCoinCell, didClickInTokenButton: UIButton?)
}

class ProjectCoinCell: UITableViewCell {
    @IBOutlet private weak var errorView: UIView!
    @IBOutlet private weak var inNumTextField: UITextField!
    @IBOutlet private weak var inTokenLabel: UILabel!
    @IBOutlet private weak var outNumTextField: UITextField!
    @IBOutlet private weak var outTokenTextField: UITextField!
    @IBOutlet private weak var costLabel: UILabel!
    
    weak var delegate: ProjectCoinCellDelegate?
    var inNum: Double = 0.00 {
        didSet {
            if inNum == 0.00 {
                inNumTextField.text = ""
            } else {
                inNumTextField.text = inNum.trueDecimalString() ?? "0.00"
            }
        }
    }
    var inToken: String? = "" {
        didSet {
            inTokenLabel.text = inToken
            inTokenLabel.textColor = .black
        }
    }
    var outNum: Double = 0.00 {
        didSet {
            if outNum == 0.00 {
                outNumTextField.text = ""
            } else {
                outNumTextField.text = outNum.trueDecimalString() ?? "0.00"
            }
        }
    }
    var outToken: String? = "" {
        didSet {
            outTokenTextField.text = outToken
        }
    }
    var error: Bool = false {
        didSet {
            errorView.isHidden = !error
        }
    }
    var valid: Bool = false {
        didSet {
            costLabel.text = "xxxxx"
        }
    }
    var didChangeInputValue: ((String?, String?, String?) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        inNumTextField.placeholder = localizedString(with: LocalizedKey.inNumPlaceholder)
        outNumTextField.placeholder = localizedString(with: LocalizedKey.outNumPlaceholder)
        outTokenTextField.placeholder = localizedString(with: LocalizedKey.outTokenPlaceholder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(inputTextFieldTextDidChange(notif:)), name: .textFieldTextDidChange, object: inNumTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(inputTextFieldTextDidChange(notif:)), name: .textFieldTextDidChange, object: outNumTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(inputTextFieldTextDidChange(notif:)), name: .textFieldTextDidChange, object: outTokenTextField)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("deinit \(type(of: self))")
    }
}

// MARK:- Events
extension ProjectCoinCell {
    @objc private func inputTextFieldTextDidChange(notif: Notification) {
        didChangeInputValue?(inNumTextField.text, outNumTextField.text, outTokenTextField.text)
    }
    
    @IBAction func inTokenButtonPressed() {
        delegate?.projectCoinCell(self, didClickInTokenButton: nil)
    }
}
