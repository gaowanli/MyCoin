//
//  LoadingView.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/16.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

enum LoadingViewStyle {
    case loading
    case success
    case error
}

class LoadingView: UIView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var loadingStyleView: UIStackView!
    @IBOutlet private weak var successErrorStyleView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var titleLabel1: UILabel!
    @IBOutlet private weak var iconButton: UIButton!
    
    private var style: LoadingViewStyle?
    private lazy var generator: UIImpactFeedbackGenerator = {
        let g = UIImpactFeedbackGenerator(style: .medium)
        g.prepare()
        return g
    }()
    
    static func view() -> LoadingView {
        return (Bundle.main.loadNibNamed("LoadingView", owner: self, options: nil)?.last) as! LoadingView
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if let s = style, s == .error {
            contentView.shake()
            generator.impactOccurred()
        }
    }
    
    func show(with title: String = "loading..", style: LoadingViewStyle? = .loading) {
        mainThread {
            self.showInWindow(with: title, style: style)
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
    
    private func showInWindow(with title: String = "loading..", style: LoadingViewStyle? = .loading) {
        titleLabel.text = title
        titleLabel1.text = title
        self.style = style
        
        switch style {
        case .loading?:
            loadingStyleView.isHidden = false
            successErrorStyleView.isHidden = true
        case .success?:
            loadingStyleView.isHidden = true
            successErrorStyleView.isHidden = false
            iconButton.tintColor = .yellowTintColor
            let image = #imageLiteral(resourceName: "icon_tips_success")
            iconButton.setImage(image, for: .normal)
            dismiss(1.0)
        case .error?:
            loadingStyleView.isHidden = true
            successErrorStyleView.isHidden = false
            iconButton.tintColor = .redTintColor
            let image = #imageLiteral(resourceName: "icon_tips_error")
            iconButton.setImage(image, for: .normal)
            dismiss(1.0)
        case .none:
            break
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
    
    private func dismiss(_ duration: Double) {
        delay(duration) {
            self.dismiss()
        }
    }
}
