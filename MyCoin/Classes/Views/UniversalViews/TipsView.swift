//
//  TipsView.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/12/8.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

enum TipsViewButtonType {
    case confirm
    case cancel
}

private struct LocalizedKey {
    static let buttonConfirm = "ButtonConfirm"
    static let buttonCancel = "ButtonCancel"
}

class TipsView: UIView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var button: UIButton!
    private var buttonType: TipsViewButtonType = .cancel
    
    var didClick: (() -> ())?
    
    static func view() -> TipsView {
        return (Bundle.main.loadNibNamed("TipsView", owner: self, options: nil)?.last) as! TipsView
    }
    
    func show(with title: String, buttonType: TipsViewButtonType = .cancel) {
        if title.isEmpty {
            return
        }
        messageLabel.text = title
        if buttonType == .confirm {
            button.setTitle(localizedString(with: LocalizedKey.buttonConfirm), for: .normal)
        } else if buttonType == .cancel {
            button.setTitle(localizedString(with: LocalizedKey.buttonCancel), for: .normal)
        } else {
            button.isHidden = true
        }
        self.buttonType = buttonType
        
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
    
    func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView.alpha = 0.5
            self.alpha = 0.0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    @IBAction func buttonPressed() {
        if buttonType == .confirm {
            didClick?()
        }
        dismiss()
    }
}
