//
//  UIView.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/6/7.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0.0
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            } else {
                return .white
            }
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
}

extension UIView {
    func round(corners: UIRectCorner, withRadius radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

// MARK:- Animations
extension UIView {
    /// 左右抖动
    func shake() {
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.duration = 0.1
        animation.fromValue = 0.0
        animation.toValue = 10.0
        animation.autoreverses = true
        layer.add(animation, forKey: "shake")
    }
    
    /// 闪烁
    func beginFlicker() {
        isHidden = false
        
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 0.5
        animation.repeatCount = MAXFLOAT
        animation.fromValue = 0.1
        animation.toValue = 0.8
        animation.autoreverses = true
        layer.add(animation, forKey: "flicker")
    }
    
    /// 结束闪烁
    func endFlicker(hidden: Bool = false) {
        isHidden = hidden
        layer.removeAnimation(forKey: "flicker")
    }
}
