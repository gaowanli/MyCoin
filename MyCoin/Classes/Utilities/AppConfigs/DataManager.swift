//
//  DataManager.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/17.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation
import CoreData
import LeanCloud
import Alamofire

struct DataManager {
    static let once = 10
    
    /// 定时同步数据
    static func syncRestoreDataIfNeed(_ completion: @escaping (Bool) -> ()) {
        guard let _ = LCUser.current?.objectId else {
            completion(false)
            return
        }
        
        let timestamp = UserDefaults.Variable.stringValue(.syncTimestamp)
        let timeout = isTimeout(timestamp: timestamp)
        completion(timeout)
    }
    
    /// 同步数据
    static func syncData(_ completion: @escaping (Bool) -> ()) {
        guard let userId = LCUser.current?.objectId else {
            completion(false)
            return
        }
        guard let userIdString = userId.rawValue as? String else {
            completion(false)
            return
        }
        
        let group = DispatchGroup()
        let aCompletion = syncDataCompletion(completion: completion)
        
        syncAllData(group: group, userIdString: userIdString, completion: aCompletion)
        
        group.notify(queue: DispatchQueue.main) {
            completion(true)
        }
    }
    
    private static func isTimeout(timestamp: String) -> Bool {
        if timestamp.isEmpty {
            return true
        } else {
            let now = Date.timestamp()
            if let l = Int(timestamp) {
                if now - l >= 6 * 3600 {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        }
    }
    
    private static func syncDataCompletion(completion: @escaping (Bool) -> ()) -> (Bool) -> () {
        return { (success) in
            if false == success {
                if let userId = LCUser.current?.objectId, let userIdString = userId.rawValue as? String {
                    let message = "同步数据时发生错误! userId:\(userIdString)"
                    ErrorManager.reportError(code: .syncFail, message: message)
                }
                completion(false)
            }
        }
    }
}

extension DataManager {
    /// 下载Plist文件
    static func downloadPlistIfNeed(completion: ((Bool) -> ())?) {
        let v = AppInfo.version
        let b = AppInfo.build
        // 新版本
        let localVersion = UserDefaults.Variable.stringValue(.version)
        if localVersion != v {
            UserDefaults.Variable.setBool(.appleInReview, true)
            UserDefaults.Variable.setString(.plistTimestamp, "")
            UserDefaults.Variable.setString(.version, v)
        }
        
        let query = LCQuery(className: LeanCloudClass.appleAuth)
        query.whereKey(AppleAuthClass.version.column, .equalTo(v))
        query.whereKey(AppleAuthClass.build.column, .equalTo(b))
        query.getFirst { (result) in
            if result.isSuccess {
                // 审核中则不下载plist
                guard let ing = result.object?.get(AppleAuthClass.ing.column)?.boolValue, false == ing else {
                    completion?(false)
                    return
                }
                UserDefaults.Variable.setBool(.appleInReview, ing)
                
                guard let timestamp = result.object?.get(AppleAuthClass.timestamp.column)?.intValue else {
                    completion?(false)
                    return
                }
                // 时间戳一样则不下载plist
                let local = UserDefaults.Variable.stringValue(.plistTimestamp)
                guard local != "\(timestamp)" else {
                    completion?(false)
                    return
                }
                var url = result.object?.get(AppleAuthClass.url.column)?.stringValue ?? ""
                if url.isEmpty {
                    url = ClouddnConfig.plistUrl
                }
                
                var updateTips: String?
                if Language.current == .chinese {
                    updateTips = result.object?.get(AppleAuthClass.updateTips.column)?.stringValue
                } else {
                    updateTips = result.object?.get(AppleAuthClass.updateTipsEN.column)?.stringValue
                }
                
                downloadPlist(url: url, timestamp: timestamp, updateTips: updateTips, completion: completion)
            }
        }
    }
    
    private static func downloadPlist(url: String, timestamp: Int, updateTips: String?, completion: ((Bool) -> ())?) {
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var url = URL(fileURLWithPath: "")
            if let toPath = LocalData.coinsPlistFilePath {
                url = URL(fileURLWithPath: toPath)
            }
            return (url, [.removePreviousFile, .createIntermediateDirectories])
        }
        Alamofire.download(url, to: destination).response { (response) in
            let success = (nil == response.error)
            if success {
                Coins.staticCoins = nil
                UserDefaults.Variable.setString(.plistTimestamp, "\(timestamp)")
                
                if let tips = updateTips {
                    mainThread {
                        TipsView.view().show(with: tips)
                    }
                }
            } else {
                let message = response.error?.localizedDescription ?? ""
                ErrorManager.reportError(code: .plistFail, message: message + url)
            }
            completion?(success)
        }
    }
}

extension DataManager {
    /// 恢复数据
    static func restoreData(_ completion: @escaping (Bool) -> ()) {
        guard let userId = LCUser.current?.objectId else {
            completion(false)
            return
        }
        guard let userIdString = userId.rawValue as? String else {
            completion(false)
            return
        }
        
        let group = DispatchGroup()
        let aCompletion = restoreDataCompletion(group: group, completion: completion)
        restoreAllData(group: group, userId: userIdString, completion: aCompletion)
    }
    
    private static func restoreDataCompletion(group: DispatchGroup, completion: @escaping (Bool) -> ()) -> (Bool) -> () {
        return { (success) in
            if false == success {
                if let userId = LCUser.current?.objectId, let userIdString = userId.rawValue as? String {
                    let message = "恢复数据时发生错误! userId:\(userIdString)"
                    ErrorManager.reportError(code: .restoreFail, message: message)
                }
                completion(false)
            } else {
                group.notify(queue: DispatchQueue.main) {
                    let timestamp = Date.timestamp()
                    UserDefaults.Variable.setString(.syncTimestamp, String(timestamp))
                    completion(true)
                }
            }
        }
    }
}

extension DataManager {
    /// 清空所有数据
    static func cleanAllLocalData() {
        cleanExchangeData()
        cleanWalletData()
        cleanCollectionData()
        cleanCoinData()
        resetSettings()
    }
    
    private static func cleanExchangeData() {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.exchange)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            try Constant.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: Constant.context)
        } catch {
        }
    }
    
    private static func cleanWalletData() {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.wallet)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            try Constant.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: Constant.context)
        } catch {
        }
    }
    
    private static func cleanCollectionData() {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.collection)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            try Constant.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: Constant.context)
        } catch {
        }
    }
    
    private static func cleanCoinData() {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.coin)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            try Constant.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: Constant.context)
        } catch {
        }
    }
    
    /// 恢复初始设置
    private static func resetSettings() {
        UserDefaults.Settings.setBool(.marketColor, false)
        UserDefaults.Settings.setBool(.authentication, false)
        UserDefaults.Settings.setBool(.usdPrice, false)
    }
}

extension DataManager {
    /// 记录用户启动次数
    static func addStartupTimes() {
        guard let user = LCUser.current else {
            return
        }
        let key = "startupTimes"
        let times = LCUser.current?.get(key)?.intValue
        if let t = times, t > 0 {
            user.set(key, value: t + 1)
        } else {
            user.set(key, value: 1)
        }
        _ = user.save()
    }
}

extension DataManager {
    /// 用户反馈
    static func addUserFeedback(userId: String, content: String, completion: @escaping ((Bool) -> ())) {
        let feedback = LCObject(className: LeanCloudClass.feedback)
        feedback.set(FeedbackClass.userObjectId.column, value: userId)
        feedback.set(FeedbackClass.content.column, value: content)
        let version = AppInfo.version
        feedback.set(FeedbackClass.version.column, value: version)
        feedback.save { (result) in
            let success = result.isSuccess
            if false == success {
                let message = "意见反馈提交失败 userId: \(userId) content: \(content) version: \(version)"
                ErrorManager.reportError(code: .feedbackFail, message: message)
            }
            completion(result.isSuccess)
        }
    }
}

extension DataManager {
    /// 未读消息
    static func fetchUnreadMessages(completion: @escaping ((Bool, LCObject?) -> ())) {
        fetchAllMessages { (success, result) in
            if let r = result, let obj = r.first {
                completion(true, obj)
            } else {
                completion(false, nil)
            }
        }
    }
    
    /// 所有消息
    static func fetchAllMessages(completion: @escaping ((Bool, [LCObject]?) -> ())) {
        let aUserQuery = LCQuery(className: LeanCloudClass.message)
        if let userId = LCUser.current?.objectId {
            aUserQuery.whereKey(MessageClass.userObjectId.column, .equalTo(userId))
        }
        
        let allUserQuery = LCQuery(className: LeanCloudClass.message)
        allUserQuery.whereKey(MessageClass.toAll.column, .equalTo(1))
        
        let query = aUserQuery.or(allUserQuery)
        query.whereKey(MessageClass.createdAt.column, .descending)
        query.find { (result) in
            completion(result.isSuccess, result.objects)
        }
    }
    
    static func pushMessage(title titleCN: String, titleEN: String, content: String, contentEN: String, toAll: Bool, completion: @escaping ((Bool) -> ())) {
        let message = LCObject(className: LeanCloudClass.message)
        message.set(MessageClass.title.column, value: titleCN)
        message.set(MessageClass.titleEN.column, value: titleEN)
        message.set(MessageClass.content.column, value: content)
        message.set(MessageClass.contentEN.column, value: contentEN)
        message.set(MessageClass.toAll.column, value: toAll ? 1 : 0)
        message.set(MessageClass.timestamp.column, value: Int32(Date.timestamp()))
        message.save({ (result) in
            completion(result.isSuccess)
        })
    }
}

