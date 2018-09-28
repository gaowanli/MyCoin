//
//  AppDelegate+document.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/10/27.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit
import LeanCloud
import Alamofire

extension AppDelegate { 
    func copyPlistToDocumentIfNeed() {
        var exists = UserDefaults.Document.boolValue(.coinsPlistExists)
        if exists {
            return
        }
        
        exists = plistInDocument()
        if (exists) {
            UserDefaults.Document.setBool(.coinsPlistExists, true)
        } else {
            copyPlistToDocument()
        }
    }
    
    /// 判断文件是否存在
    func plistInDocument() -> Bool {
        guard let path = LocalData.coinsPlistFilePath else {
            return false
        }
        
        return FileManager.default.fileExists(atPath: path)
    }
    
    /// 将bundle中的Coins.plist拷贝到沙盒documents目录
    func copyPlistToDocument() {
        guard let toPath = LocalData.coinsPlistFilePath else {
            return
        }
        
        let file = LocalData.coinsPlistFileName
        let path = Bundle.main.path(forResource: file, ofType: nil)
        
        guard let p = path else {
            return
        }
        
        var fail = false
        do {
            try FileManager.default.copyItem(atPath: p, toPath: toPath)
        } catch {
            fail = true
            UserDefaults.Document.setBool(.coinsPlistExists, false)
        }
        
        if false == fail {
            UserDefaults.Document.setBool(.coinsPlistExists, true)
        }
    }
}
