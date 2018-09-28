//
//  TabBar.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/13.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

protocol TabBarDelegate: NSObjectProtocol {
    /**
     点击了某个按钮
     
     - parameter tabBar: tabBar
     - parameter index:  按钮index
     */
    func tabBar(_ tabBar: TabBar, didClickButton index: Int)
}

class TabBar: UITabBar {
    weak var aDelegate: TabBarDelegate? 
    private var selButton: DHButton?
    private lazy var buttonTitles: [String] = {
        let assets = commonLocalizedString(with: CommonLocalizedKey.assets)
        let settings = commonLocalizedString(with: CommonLocalizedKey.settings)
        let titles = [assets, settings]
        return titles
    }()
    private lazy var buttons: [UIButton] = {
        return [UIButton]()
    }()
    private lazy var indicators: [UIView] = {
        return [UIView]()
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        for title in buttonTitles {
            let indicator = UIView()
            indicator.isHidden = true
            indicator.backgroundColor = .yellowTintColor
            indicators.append(indicator)
            
            let button = buttonWithTitle(title)
            button.tag = buttons.count
            if button.tag == 0 {
                buttonPressed(button)
            }
            buttons.append(button)
            
            addSubview(indicator)
            addSubview(button)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let count = buttons.count
        let w = bounds.width / CGFloat(count)
        let h: CGFloat = 49.0
        
        let frame = CGRect(x: 0, y: 0, width: w, height: h)
        for button in buttons {
            button.frame = frame.offsetBy(dx: CGFloat(button.tag) * w, dy: 0)
            let indicator = indicators[button.tag]
            let indicatorW: CGFloat = button.bounds.width * 0.5
            let indicatorH: CGFloat = 3.0
            let indicatorX = button.frame.minX + indicatorW * 0.5
            var indicatorY: CGFloat = button.frame.maxY - 2 * indicatorH
            if UIDevice.displayNotched {
                indicatorY = button.frame.maxY - indicatorH
            }
            indicator.layer.cornerRadius = indicatorH * 0.5
            indicator.layer.masksToBounds = true
            indicator.frame = CGRect(x: indicatorX, y: indicatorY, width: indicatorW, height: indicatorH)
        }
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            var tmp = newValue
            if let superview = self.superview, tmp.maxY != superview.frame.height {
                tmp.origin.y = superview.frame.height - tmp.height
            }
            super.frame = tmp
        }
    }
    
    private func buttonWithTitle(_ title: String) -> DHButton {
        let button = DHButton(type: .custom)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14.0)
        button.setTitle(title, for: .normal)
        button.setTitle(title, for: .selected)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.yellowTintColor, for: .selected)
        button.addTarget(self, action: #selector(TabBar.buttonPressed(_:)), for: .touchDown)
        return button
    }
    
    @objc func buttonPressed(_ button: DHButton) {
        guard selButton != button else {
            return
        }
        
        let selIndicator = indicators[selButton?.tag ?? 0]
        selIndicator.isHidden = true
        selButton?.isSelected = false
        
        let indicator = indicators[button.tag]
        indicator.isHidden = false
        button.isSelected = true
        selButton = button
        aDelegate?.tabBar(self, didClickButton: button.tag)
    }
}
