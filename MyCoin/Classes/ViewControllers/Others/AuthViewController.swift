//
//  AuthViewController.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/29.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

private struct LocalizedKey {
    static let faceIDTips = "FaceIDTips"
    static let touchIDTips = "TouchIDTips"
    static let authSuccess = "AuthSuccess"
    static let authFailRetry = "AuthFailRetry"
}

class AuthViewController: UIViewController, DefaultStatusBarStyle {
    @IBOutlet private weak var tipsButton: UIButton!
    @IBOutlet private weak var tipsLabel: UILabel!
    @IBOutlet private weak var tipsStackView: UIStackView!
    @IBOutlet private weak var logoCenterY: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        translateStrings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animation()
    }
    
    deinit {
        print("deinit \(type(of: self))")
    }
}

// MARK:- Events
extension AuthViewController {
    @IBAction func enterButtonPressed() {
        auth()
    }
}

// MARK:- Methods
extension AuthViewController {
    private func setup() {
        tipsStackView.isHidden = true
    }
    
    private func translateStrings() {
        if UIDevice.supportTouchID {
            tipsButton.setImage(#imageLiteral(resourceName: "icon_face_id"), for: .normal)
            tipsLabel.text = localizedString(with: LocalizedKey.faceIDTips)
        } else {
            tipsButton.setImage(#imageLiteral(resourceName: "icon_touch_id"), for: .normal)
            tipsLabel.text = localizedString(with: LocalizedKey.touchIDTips)
        }
    }
    
    private func auth() {
        let reason = commonLocalizedString(with: CommonLocalizedKey.authTips)
        UIDevice.auth(reason: reason) { (success) in
            mainThread {
                if success {
                    self.tipsLabel.text = self.localizedString(with: LocalizedKey.authSuccess)
                    self.tipsLabel.endFlicker()
                    NotificationCenter.default.post(name: .rootVCToTabBarVC, object: nil)
                } else {
                    self.tipsLabel.text = self.localizedString(with: LocalizedKey.authFailRetry)
                    self.tipsLabel.beginFlicker()
                    delay(1.0, closure: {
                        self.tipsLabel.endFlicker()
                    })
                }
            }
        }
    }
    
    private func animation() {
        self.logoCenterY.constant = -160.0 * Constant.screenWidth / 375.0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            self.tipsStackView.isHidden = false
            self.auth()
        }
    }
}
