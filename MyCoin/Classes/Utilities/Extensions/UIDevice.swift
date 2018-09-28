//
//  UIDevice.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/10/30.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit
import MessageUI
import LocalAuthentication

extension UIDevice {
    /// 是否是刘海屏
    static var displayNotched: Bool {
        return UIDevice.deviceDisplayNotched
    }
    
    /// 是否支持TouchID
    static var supportTouchID: Bool {
        return UIDevice.deviceSupportTouchID
    }
    
    /// 是否支持FaceID
    static var supportFaceID: Bool {
        return UIDevice.deviceSupportFaceID
    }
    
    /// 是否支持发送邮件
    static var supportSendEmail: Bool {
        return UIDevice.deviceSupportSendEmail
    }
    
    /// 请求TouchID或者FaceID授权
    static func auth(reason: String, completion: @escaping (Bool) -> ()) {
        let context = LAContext()
        context.localizedFallbackTitle = ""
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, e) in
            if let error = e as NSError? {
                if error.code != LAError.userCancel.rawValue, error.code != LAError.appCancel.rawValue, error.code != LAError.systemCancel.rawValue {
                    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason, reply: { (success, _) in
                        completion(success)
                    })
                }
            } else {
                completion(success)
            }
        }
    }
}

extension UIDevice {
    private static let deviceDisplayNotched: Bool = {
        let screenBounds = UIScreen.main.bounds
        let width = min(screenBounds.width, screenBounds.height)
        let height = max(screenBounds.width, screenBounds.height)
        return width / height < 9.0 / 16.0
    }()
    
    private static let deviceSupportTouchID: Bool = {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if #available(iOS 11.0, *) {
                return (error == nil && context.biometryType == .touchID)
            } else {
                return (error == nil)
            }
        } else {
            if let code = error?.code, code == kLAErrorBiometryLockout {
                return true
            }
            return false
        }
    }()
    
    private static let deviceSupportFaceID: Bool = {
        if #available(iOS 11.0, *) {
            let context = LAContext()
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                return (error == nil && context.biometryType == .faceID)
            } else {
                if context.biometryType == .faceID, let code = error?.code, code == kLAErrorBiometryLockout {
                    return true
                }
                return false
            }
        } else {
            return false
        }
    }()
    
    private static let deviceSupportSendEmail: Bool = {
        return MFMailComposeViewController.canSendMail()
    }()
}
