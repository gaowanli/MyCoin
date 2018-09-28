//
//  Double.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/5.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation

extension Double {
    func isDecimal() -> Bool {
        let scan = Scanner(string: "\(self)")
        var val = 0.00
        return scan.scanDouble(&val) && scan.isAtEnd
    }
    
    /// 格式化成真实的金额显示 最多6位小数点 小数点最后一位不带0
    func trueDecimalString() -> String? {
        return aTrimZeroDecimalString()
    }
    
    /// 格式化成金额显示 小于1最多6位小数点 大于等于1最多2位小数点 不够2位小数用0补齐
    func decimalString() -> String? {
        if self < 1.00 {
            return aTrimZeroDecimalString()
        } else {
            return aDecimalString()
        }
    }
    
    /// 格式化成数量显示 小于1最多6位小数点 大于等于1最多2位小数点 小数点最后一位不带0
    func numDecimalString() -> String? {
        if self < 1.00 {
            return aTrimZeroDecimalString()
        } else {
            return aTrimZeroNumDecimalString()
        }
    }
    
    func dateString() -> String {
        let formatter = Constant.dateFormatter
        formatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        let date = Date(timeIntervalSince1970: self)
        return formatter.string(from: date)
    }
    
    private func aTrimZeroDecimalString() -> String? {
        if self < Constant.minNumber {
            return self > 0.00 ? "" : "0.00"
        }
        
        var numStr = String(format: "%.6f", self)
        if numStr.components(separatedBy: ".").last == "000000" {
            let n = Int(self)
            numStr = "\(n)"
        } else if let s = numStr.components(separatedBy: ".").last, s.hasSuffix("00000") {
            numStr = String(format: "%.1f", self)
        } else if let s = numStr.components(separatedBy: ".").last, s.hasSuffix("0000") {
            numStr = String(format: "%.2f", self)
        } else if let s = numStr.components(separatedBy: ".").last, s.hasSuffix("000") {
            numStr = String(format: "%.3f", self)
        } else if let s = numStr.components(separatedBy: ".").last, s.hasSuffix("00") {
            numStr = String(format: "%.4f", self)
        } else if let s = numStr.components(separatedBy: ".").last, s.hasSuffix("0") {
            numStr = String(format: "%.5f", self)
        }
        return numStr
    }
    
    private func aTrimZeroNumDecimalString() -> String? {
        if self < Constant.minNumber {
            return self > 0.00 ? "" : "0.00"
        }
        
        var numStr = String(format: "%.2f", self)
        if numStr.components(separatedBy: ".").last == "00" {
            let n = Int(self)
            numStr = "\(n)"
        } else if let s = numStr.components(separatedBy: ".").last, s.hasSuffix("0") {
            numStr = String(format: "%.1f", self)
        }
        return numStr
    }
    
    private func aDecimalString() -> String? {
        let formatter = Constant.numberFormater
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self))
    }
}
