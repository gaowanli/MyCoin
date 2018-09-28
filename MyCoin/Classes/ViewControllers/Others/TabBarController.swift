//
//  TabBarController.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/13.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit
import StoreKit
import LeanCloud

class TabBarController: UITabBarController {
    @IBOutlet private weak var aTabBar: TabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aTabBar.aDelegate = self
        automaticSignInIfNeed()
        automaticSyncRestoreDataIfNeed()
        promptScoreIfNeed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        removeSystemTabbarSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        removeSystemTabbarSubviews()
    }
    
    private func removeSystemTabbarSubviews() {
        for v in tabBar.subviews {
            if v.superclass == UIControl.self {
                v.removeFromSuperview()
            }
        }
    }
}

extension TabBarController: TabBarDelegate {
    func tabBar(_ tabBar: TabBar, didClickButton index: Int) {
        selectedIndex = index
    }
}

extension TabBarController {
    /// 自动登陆
    private func automaticSignInIfNeed() {
        let userName = UserDefaults.UserInfo.stringValue(.userName)
        let password = UserDefaults.UserInfo.stringValue(.password)
        if userName.isEmpty || password.isEmpty {
            fetchUnreadMessages()
            return
        } else {
            automaticSignIn(userName: userName, password: password, times: 0, error: nil)
        }
    }
    
    private func automaticSignIn(userName: String, password: String, times: Int, error: String?) {
        guard times < 10 else {
            ErrorManager.reportError(code: .signInFail, message: "自动登录失败 userName:\(userName) password:\(password) \(error ?? "")")
            return
        }
        LCUser.logIn(username: userName, password: password, completion: { [weak self] (result) in
            if let strongSelf = self {
                if result.isSuccess {
                    strongSelf.fetchUnreadMessages()
                    DataManager.addStartupTimes()
                } else {
                    strongSelf.automaticSignIn(userName: userName, password: password, times: times + 1, error: result.error?.localizedDescription)
                }
            }
        })
    }
    
    /// 备份、同步数据
    private func automaticSyncRestoreDataIfNeed() {
        DataManager.syncRestoreDataIfNeed { [weak self] (need) in
            if let strongSelf = self, need {
                strongSelf.syncRestoreData()
            }
        }
    }
    
    private func syncRestoreData() {
        let loading = LoadingView.view()
        loading.show(with: commonLocalizedString(with: CommonLocalizedKey.syncTips))
        DataManager.syncData({ [weak self] (success) in
            if let strongSelf = self {
                if success {
                    strongSelf.restoreData(loading: loading)
                } else {
                    loading.dismiss()
                }
            }
        })
    }
    
    private func restoreData(loading: LoadingView) {
        DataManager.restoreData({ [weak self] (success) in
            if let strongSelf = self {
                if success {
                    mainThread {
                        NotificationCenter.default.post(name: .autoRestoreDataSuccess, object: nil, userInfo: nil)
                    }
                    let message = strongSelf.commonLocalizedString(with: CommonLocalizedKey.syncSuccess)
                    loading.show(with: message, style: .success)
                } else {
                    loading.dismiss()
                }
            }
        })
    }
    
    /// 提示用户评分
    private func promptScoreIfNeed() {
        let startupTimes = UserDefaults.Variable.intValue(.startupTimes)
        let t = Double(startupTimes)
        guard startupTimes > 5, t.truncatingRemainder(dividingBy: 3) == 0 else {
            return
        }
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
    
    /// 获取未读消息
    private func fetchUnreadMessages() {
        DataManager.fetchUnreadMessages { (success, message) in
            if success {
                guard let timestamp = message?.get(MessageClass.timestamp.column)?.intValue else {
                    return
                }

                // 时间戳一样则不显示消息
                let local = UserDefaults.Variable.stringValue(.messageTimestamp)
                guard local != "\(timestamp)" else {
                    return
                }
                
                var title = ""
                let titleCN = message?.get(MessageClass.title.column)?.stringValue ?? ""
                let titleEN = message?.get(MessageClass.titleEN.column)?.stringValue ?? ""
                let cn = (Language.current == .chinese)
                title = (cn ? titleCN : titleEN)
                mainThread {
                    let tipsView = TipsView.view()
                    tipsView.show(with: title, buttonType: .confirm)
                    tipsView.didClick = { [weak self] in
                        if let strongSelf = self {
                            UserDefaults.Variable.setString(.messageTimestamp, "\(timestamp)")
                            
                            let vc = UIStoryboard.load(from: .main, withId: .messageDetail) as! MessageDetailViewController
                            vc.message = message
                            if let navVC = strongSelf.selectedViewController as? UINavigationController {
                                navVC.pushViewController(vc, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
}
