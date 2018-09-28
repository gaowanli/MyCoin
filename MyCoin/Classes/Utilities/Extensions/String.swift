//
//  String.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/3.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func trimWhitespaces() -> String {
        guard self.count > 0 else {
            return ""
        }
        return trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    func decimalValue() -> Double {
        var str = self
        if str.contains(",") {
            str = str.replacingOccurrences(of: ",", with: ".")
        }
        return Double(str) ?? 0.00
    }
    
    func isDate() -> Bool {
        let formatter = Constant.dateFormatter
        formatter.dateFormat = "yyyy.MM.dd"
        let date = formatter.date(from: self)
        return nil != date
    }
    
    func isEmail() -> Bool {
        let predicateStr = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", predicateStr)
        return predicate.evaluate(with: self)
    }
    
    func height(byFont font: UIFont, andMaxWidth maxWidth: CGFloat, andMaxHeight maxHeight: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGFloat {
        return size(byFont: font, andMaxWidth: maxWidth, andMaxHeight: maxHeight).height
    }
    
    private func size(byFont font: UIFont, andMaxWidth maxWidth: CGFloat, andMaxHeight maxHeight: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGSize {
        let text = self as NSString
        let size = CGSize(width: maxWidth, height: maxHeight)
        let attributes = [NSAttributedString.Key.font: font]
        return text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
    }
}
