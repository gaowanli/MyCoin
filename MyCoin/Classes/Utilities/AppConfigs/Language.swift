//
//  Language.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/29.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation

enum LanguageType {
    case chinese
    case other
}

struct Language {
    static var current: LanguageType {
        return Language.currentLanguage
    }
    
    private static let currentLanguage: LanguageType = {
        var language = ""
        if let languages = UserDefaults.standard.object(forKey: "AppleLanguages") as? [Any] {
            if let l = languages.first as? String {
                language = l
            }
        }
        let isChinese = (language == "zh" || language.hasPrefix("zh-Hans"))
        return (isChinese ? .chinese : .other)
    }()
}
