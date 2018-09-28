//
//  SettingsViewController.swift
//  MyCoin
//
//  Created by GaoWanli on 12/02/2018.
//  Copyright © 2018 wl. All rights reserved.
//

import UIKit
import MessageUI
import LeanCloud
import LocalAuthentication

private struct LocalizedKey {
    static let basic = "BasicSetting"
    static let system = "SystemSetting"
    static let other = "OtherSetting"
    static let marketColor = "MarketColor"
    static let usdPrice = "PriceUSD"
    static let syncData = "SyncData"
    static let shareMessage = "ShareMessage"
    static let feedbackThanks = "FeedbackThanks"
    static let signInTips = "SignInTips"
}

class SettingsViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var currentUserLabel: UILabel!
    @IBOutlet private weak var signInButton: UIButton!
    @IBOutlet private weak var navViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var headerViewHeight: NSLayoutConstraint!
    
    private lazy var secionTitles: [String] = {
        let basic = localizedString(with: LocalizedKey.basic)
        let system = localizedString(with: LocalizedKey.system)
        let other = localizedString(with: LocalizedKey.other)
        return [basic, system, other]
    }()
    private lazy var firstSecionTitles: [String] = {
        let collection = commonLocalizedString(with: CommonLocalizedKey.collection)
        let wallet = commonLocalizedString(with: CommonLocalizedKey.myWallet)
        let exchange = commonLocalizedString(with: CommonLocalizedKey.myExchange)
        return [collection, wallet, exchange]
    }()
    private lazy var secondSecionTitles: [String] = {
        let currency = commonLocalizedString(with: CommonLocalizedKey.currency)
        let percentChange = commonLocalizedString(with: CommonLocalizedKey.percentChange)
        return [currency, percentChange]
    }()
    private lazy var thirdSecionTitles: [String] = {
        let feedback = commonLocalizedString(with: CommonLocalizedKey.feedback)
        return [feedback]
    }()
    private var pushButtonPressedTime = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        translateStrings()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if UIDevice.displayNotched {
            navViewHeight.constant = 88.0
        }
        headerViewHeight.constant = 155.0 * Constant.screenHeight / 568.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupUserInfoView()
    }
    
    deinit {
        print("deinit \(type(of: self))")
    }
}

// MARK:- Events
extension SettingsViewController {
    @IBAction func messageButtonPressed() {
        let vc = UIStoryboard.load(from: .main, withId: .message)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func shareButtonPressed() {
        let message = localizedString(with: LocalizedKey.shareMessage)
        let url = URL(string: AppStore.downloadUrl)!
        let vc = UIActivityViewController(activityItems: [message, url], applicationActivities: nil)
        present(vc, animated: true)
    }
    
    @IBAction func pushMessageButtonPressed() {
        let userId = LCUser.current?.objectId?.stringValue
        if userId == Developer.userId {
            pushButtonPressedTime = pushButtonPressedTime + 1
            
            if pushButtonPressedTime == 5 {
                pushButtonPressedTime = 0
                let vc = UIStoryboard.load(from: .main, withId: .pushMessage)
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func signInButtonPressed() {
        if let _ = LCUser.current {
            let alert = AlertView.view()
            alert.show(with: commonLocalizedString(with: CommonLocalizedKey.logOutTips), buttonStyle: .both)
            alert.didClickButton = { [weak self] (index) in
                // 注销
                if let strongSelf = self, index == 1 {
                    strongSelf.syncDataLogOut()
                }
            }
        } else {
            // 登陆
            let vc = UIStoryboard.load(from: .main, withId: .signIn) as! UserSignInViewController
            vc.didChangeUserState = { [weak self] in
                if let strongSelf = self {
                    strongSelf.tableView.reloadData()
                }
            }
            present(vc, animated: true)
        }
    }
}

// MARK:- Methods
extension SettingsViewController {
    private func setup() {
        tableView.registerNibCell(with: ItemCell.self)
        tableView.registerNibCell(with: SwitchCell.self)
        tableView.registerNibHeaderFooter(with: GroupHeaderView.self)
        tableView.rowHeight = 50.0
    }
    
    private func translateStrings() {
        setCommonLocalizedString(with: titleLabel, key: CommonLocalizedKey.settings)
    }
    
    private func setupUserInfoView() {
        if let user = LCUser.current, let name = user.username?.rawValue {
            currentUserLabel.text = "\(name)"
            currentUserLabel.textColor = .white
            signInButton.setTitleColor(.redColor, for: .normal)
            signInButton.setTitle(commonLocalizedString(with: CommonLocalizedKey.logOut), for: .normal)
        } else {
            currentUserLabel.text = localizedString(with: LocalizedKey.signInTips)
            currentUserLabel.textColor = UIColor.init(white: 255.0, alpha: 0.5)
            signInButton.setTitleColor(.yellowTintColor, for: .normal)
            signInButton.setTitle(commonLocalizedString(with: CommonLocalizedKey.signIn), for: .normal)
        }
    }
    
    private func syncDataLogOut() {
        syncData { [weak self] (success) in
            if let strongSelf = self {
                if success {
                    DataManager.cleanAllLocalData()
                    strongSelf.logOut()
                } else {
                    let alert = AlertView.view()
                    let message = strongSelf.commonLocalizedString(with: CommonLocalizedKey.syncErrorLogOut)
                    alert.show(with: message, buttonStyle: .both)
                    alert.didClickButton = { [weak self] (buttonIndex) in
                        if let strongSelf = self {
                            if buttonIndex == 0 {
                                strongSelf.syncDataLogOut()
                            } else {
                                strongSelf.logOut()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func logOut() {
        LCUser.logOut()
        UserDefaults.UserInfo.setString(.password, "")
        setupUserInfoView()
        tableView.reloadData()
    }
    
    private func syncData(completion: @escaping (Bool) -> ()) {
        let loading = LoadingView.view()
        loading.show(with: commonLocalizedString(with: CommonLocalizedKey.syncTips))
        
        DataManager.syncData({ (success) in
            loading.dismiss()
            completion(success)
        })
    }
    
    private func syncRestoreData() {
        let loading = LoadingView.view()
        loading.show()
        
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
                if false == success {
                    strongSelf.syncRestoreDataFail(loading: loading)
                } else {
                    loading.show(with: strongSelf.commonLocalizedString(with: CommonLocalizedKey.syncSuccess), style: .success)
                    mainThread {
                        strongSelf.tableView.reloadData()
                    }
                }
            }
        })
    }
    
    private func syncRestoreDataFail(loading: LoadingView) {
        let alert = AlertView.view()
        alert.show(with: commonLocalizedString(with: CommonLocalizedKey.syncErrorRetry), buttonStyle: .both)
        alert.didClickButton = { [weak self] (buttonIndex) in
            if let strongSelf = self {
                if buttonIndex == 1 {
                    strongSelf.restoreData(loading: loading)
                } else {
                    loading.dismiss()
                }
            }
        }
    }
    
    private func supportAuth() -> Bool {
        return (UIDevice.supportFaceID || UIDevice.supportTouchID)
    }
    
    private func auth(open: Bool) {
        let reason = commonLocalizedString(with: CommonLocalizedKey.authTips)
        UIDevice.auth(reason: reason) { (success) in
            if success {
                UserDefaults.Settings.setBool(.authentication, open)
            }
            mainThread {
                self.tableView.reloadData()
            }
        }
    }
    
    private func feedbackByEmail() {
        let loading = LoadingView.view()
        loading.show()
        
        AnalysisManager.analysis { [weak self] (logFile) in
            if let strongSelf = self {
                if let file = logFile {
                    loading.dismiss()
                    strongSelf.sendEmail(logFile: file)
                } else {
                    let message = strongSelf.commonLocalizedString(with: CommonLocalizedKey.errorRetry)
                    loading.show(with: message, style: .error)
                }
            }
        }
    }
    
    private func sendEmail(logFile: String) {
        if let fileData = NSData(contentsOfFile: logFile) as Data? {
            let vc = MFMailComposeViewController()
            vc.mailComposeDelegate = self
            vc.setSubject("log.txt")
            vc.setToRecipients([Developer.email])
            vc.addAttachmentData(fileData, mimeType: "", fileName: "log.txt")
            present(vc, animated: true)
        } else {
            let loading = LoadingView.view()
            let message = commonLocalizedString(with: CommonLocalizedKey.errorRetry)
            loading.show(with: message, style: .error)
        }
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return firstSecionTitles.count
        } else if section == 1 {
            return secondSecionTitles.count + 2
        } else if section == 2 {
            let login = (nil != LCUser.current ? 1 : 0)
            let auth = (supportAuth() ? 1 : 0)
            return thirdSecionTitles.count + login + auth
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            let cell = tableView.dequeueReusableNibCell(with: ItemCell.self) as! ItemCell
            cell.title = firstSecionTitles[indexPath.row]
            return cell
        case (1, 2):
            let cell = tableView.dequeueReusableNibCell(with: SwitchCell.self) as! SwitchCell
            cell.title = localizedString(with: LocalizedKey.marketColor)
            cell.switchOn = UserDefaults.Settings.boolValue(.marketColor)
            cell.didChangeSwitchOn = { (on) in
                let old = UserDefaults.Settings.boolValue(.marketColor)
                if old != on {
                    UserDefaults.Settings.setBool(.marketColor, on)
                }
            }
            return cell
        case (1, 3):
            let cell = tableView.dequeueReusableNibCell(with: SwitchCell.self) as! SwitchCell
            cell.title = localizedString(with: LocalizedKey.usdPrice)
            cell.switchOn = UserDefaults.Settings.boolValue(.usdPrice)
            cell.didChangeSwitchOn = { (on) in
                let old = UserDefaults.Settings.boolValue(.usdPrice)
                if old != on {
                    UserDefaults.Settings.setBool(.usdPrice, on)
                }
            }
            return cell
        case (1, _):
            let cell = tableView.dequeueReusableNibCell(with: ItemCell.self) as! ItemCell
            cell.title = secondSecionTitles[indexPath.row]
            return cell
        case (2, 0):
            let cell = tableView.dequeueReusableNibCell(with: ItemCell.self) as! ItemCell
            cell.title = thirdSecionTitles[indexPath.row]
            return cell
        case (2, 1):
            if supportAuth() {
                let cell = tableView.dequeueReusableNibCell(with: SwitchCell.self) as! SwitchCell
                let faceTitle = commonLocalizedString(with: CommonLocalizedKey.faceID)
                let touchTitle = commonLocalizedString(with: CommonLocalizedKey.touchID)
                cell.title = (UIDevice.supportFaceID ? faceTitle : touchTitle)
                cell.switchOn = UserDefaults.Settings.boolValue(.authentication)
                cell.didChangeSwitchOn = { [weak self] (on) in
                    if let strongSelf = self {
                        strongSelf.auth(open: on)
                    }
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableNibCell(with: ItemCell.self) as! ItemCell
                let title = localizedString(with: LocalizedKey.syncData)
                let timestamp = UserDefaults.Variable.stringValue(.syncTimestamp)
                if let t = Double(timestamp), t > 0.00 {
                    cell.title = title + "|\(t.dateString())"
                } else {
                    cell.title = title
                }
                return cell
            }
        case (2, 2):
            let cell = tableView.dequeueReusableNibCell(with: ItemCell.self) as! ItemCell
            let title = localizedString(with: LocalizedKey.syncData)
            let timestamp = UserDefaults.Variable.stringValue(.syncTimestamp)
            if let t = Double(timestamp), t > 0.00 {
                cell.title = title + "|\(t.dateString())"
            } else {
                cell.title = title
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = tableView(tableView, heightForHeaderInSection: 0)
        let offsetY = scrollView.contentOffset.y
        
        if offsetY <= height, offsetY >= 0 {
            scrollView.contentInset = UIEdgeInsets(top: -offsetY, left: 0.0, bottom: 0.0, right: 0.0)
        } else if offsetY >= height {
            scrollView.contentInset = UIEdgeInsets(top: -height, left: 0.0, bottom: 0.0, right: 0.0)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooter(with: GroupHeaderView.self) as! GroupHeaderView
        view.title = secionTitles[section]
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return 4.0
        } else {
            return 0.0001
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var vc: UIViewController?
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            vc = UIStoryboard.load(from: .main, withId: .collection)
        case (0, 1):
            vc = UIStoryboard.load(from: .main, withId: .wallet)
        case (0, 2):
            vc = UIStoryboard.load(from: .main, withId: .exchange)
        case (1, 0):
            vc = UIStoryboard.load(from: .main, withId: .currency)
        case (1, 1):
            vc = UIStoryboard.load(from: .main, withId: .percent)
        case (2, 0):
            if UIDevice.supportSendEmail {
                feedbackByEmail()
            } else {
                vc = UIStoryboard.load(from: .main, withId: .feedback)
            }
        case (2, 1):
            if false == supportAuth() {
                syncRestoreData()
            }
        case (2, 2):
            if supportAuth() {
                syncRestoreData()
            }
        default:
            break
        }
        
        if let v = vc {
            navigationController?.pushViewController(v, animated: true)
        }
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        let loading = LoadingView.view()
        if result == .sent {
            let message = localizedString(with: LocalizedKey.feedbackThanks)
            loading.show(with: message, style: .success)
            dismiss(animated: true)
        } else if result == .failed {
            let message = commonLocalizedString(with: CommonLocalizedKey.errorRetry)
            loading.show(with: message, style: .error)
        } else {
            dismiss(animated: true)
        }
    }
}
