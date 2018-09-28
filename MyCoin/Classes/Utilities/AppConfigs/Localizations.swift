//
//  Localizations.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/29.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation 

struct Localizations {
    static func string(with key: String) -> String {
        let resource = (Language.current == .chinese) ? "zh" : "en"
        if let path = Bundle.main.path(forResource: resource, ofType: ".lproj") {
            if let bundle = Bundle(path: path) {
                return bundle.localizedString(forKey: key, value: nil, table: "Localized")
            }
            return ""
        } else {
            return ""
        }
    }
}
