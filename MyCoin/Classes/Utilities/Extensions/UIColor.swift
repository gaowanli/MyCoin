//
//  UIColor.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/6/7.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit
import CoreGraphics

extension UIColor {
    static func rgba(_ r: Float, g: Float, b: Float, a: Float = 1.0) -> UIColor {
        return UIColor(red: CGFloat(r / 255.0), green: CGFloat(g / 255.0), blue: CGFloat(b / 255.0), alpha: CGFloat(a))
    }
    
    static func hexa(value: UInt32) -> UIColor {
        let r = CGFloat((value & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((value & 0xFF00) >> 8) / 255.0
        let b = CGFloat((value & 0xFF)) / 255.0
        let a = CGFloat((value & 0xFF000000) >> 24) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    static func hex(value: UInt32) -> UIColor {
        let r = CGFloat((value & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((value & 0xFF00) >> 8) / 255.0
        let b = CGFloat((value & 0xFF)) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    static var random: UIColor {
        let r:CGFloat = CGFloat(drand48())
        let g:CGFloat = CGFloat(drand48())
        let b:CGFloat = CGFloat(drand48())
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    var hexString: String? {
        let components = self.cgColor.components
        guard let rgb = components else {
            return nil
        }
        
        let r = rgb[0]
        let g = rgb[1]
        let b = rgb[2]
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
