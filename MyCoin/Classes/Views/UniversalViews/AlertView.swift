//
//  AlertView.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/13.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

enum AlertViewButtonStyle {
    case ok
    case both
}

private struct LocalizedKey {
    static let title = "Title"
}

class AlertView: UIView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var rightButtonToSuperLeft: NSLayoutConstraint!
    @IBOutlet private weak var rightButtonToLeftButtonLeft: NSLayoutConstraint!
    
    var didClickButton: ((Int) -> ())?
    
    static func view() -> AlertView {
        return (Bundle.main.loadNibNamed("AlertView", owner: self, options: nil)?.last) as! AlertView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setCommonLocalizedString(with: leftButton, key: CommonLocalizedKey.cancel)
        setCommonLocalizedString(with: rightButton, key: CommonLocalizedKey.confirm)
    }
    
    func show(with message: String, buttonStyle: AlertViewButtonStyle = .ok) {
        titleLabel.text = localizedString(with: LocalizedKey.title)
        messageLabel.text = message
        
        if .ok == buttonStyle {
            rightButtonToSuperLeft.priority = .defaultHigh
            rightButtonToLeftButtonLeft.priority = .defaultLow
            leftButton.isHidden = true
        }
        
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
}

// MARK:- Events
extension AlertView {
    @IBAction func buttonPressed(_ button: UIButton) {
        if leftButton == button {
            didClickButton?(0)
        } else if rightButton == button {
            didClickButton?(1)
        }
        dismiss()
    }
}
