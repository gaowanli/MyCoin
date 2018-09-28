//
//  UserDefaults.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/6/7.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation

protocol UserDefaultsNameSpace {
}

extension UserDefaultsNameSpace {
    static func namespace<T>(_ key: T) -> String where T: RawRepresentable {
        return "\(Self.self).\(key.rawValue)"
    }
}

protocol UserDefaultsSettable: UserDefaultsNameSpace {
    associatedtype UserDefaultKey: RawRepresentable
}

extension UserDefaultsSettable where UserDefaultKey.RawValue == String {
    static func setInt(_ key: UserDefaultKey, _ value: Int) {
        let k = namespace(key)
        UserDefaults.standard.set(value, forKey: k)
        UserDefaults.standard.synchronize()
    }
    
    static func intValue(_ key: UserDefaultKey) -> Int {
        let k = namespace(key)
        return UserDefaults.standard.integer(forKey: k)
    }
    
    static func setBool(_ key: UserDefaultKey, _ value: Bool) {
        let k = namespace(key)
        UserDefaults.standard.set(value, forKey: k)
        UserDefaults.standard.synchronize()
    }
    
    static func boolValue(_ key: UserDefaultKey) -> Bool {
        let k = namespace(key)
        return UserDefaults.standard.bool(forKey: k)
    }
    
    static func setString(_ key: UserDefaultKey, _ value: String) {
        let k = namespace(key)
        UserDefaults.standard.set(value, forKey: k)
        UserDefaults.standard.synchronize()
    }
    
    static func stringValue(_ key: UserDefaultKey) -> String {
        let k = namespace(key)
        if let result = UserDefaults.standard.string(forKey: k) {
            return result
        } else {
            return ""
        }
    }
}
