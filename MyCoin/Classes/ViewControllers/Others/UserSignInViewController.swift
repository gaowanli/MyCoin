//
//  UserSignInViewController.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/16.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit
import LeanCloud

private struct LocalizedKey {
    static let namePasswordError = "ErrorNamePasswordError"
    static let retryLater = "RetryLater"
}

class UserSignInViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var signUpButton: UIButton!
    @IBOutlet private weak var signInButton: UIButton!
    @IBOutlet private weak var userNameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var findPasswordButton: UIButton!
    @IBOutlet private weak var navViewHeight: NSLayoutConstraint!
    
    var didChangeUserState: (() -> ())?
    private var userName: String {
        return self.userNameTextField.text ?? ""
    }
    private var password: String {
        return self.passwordTextField.text ?? ""
    }
    private var signUserName: String = ""
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        translateStrings()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if UIDevice.displayNotched {
            navViewHeight.constant = 88.0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let userName = UserDefaults.UserInfo.stringValue(.userName)
        if !userName.isEmpty {
            userNameTextField.text = userName
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let userName = UserDefaults.UserInfo.stringValue(.userName)
        if userName.isEmpty {
            userNameTextField.becomeFirstResponder()
        } else {
            passwordTextField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
    }
    
    deinit {
        print("deinit \(type(of: self))")
    }
}

// MARK:- Events
extension UserSignInViewController {
    @IBAction func closeButtonPressed() {
        dismiss(animated: true)
    }
    
    @IBAction func signUpButtonPressed() {
        let vc = UIStoryboard.load(from: .main, withId: .signUp) as! UserSignUpViewController
        vc.didClickCloseButton = { [weak self] in
            if let strongSelf = self {
                strongSelf.presentingViewController?.dismiss(animated: false)
            }
        }
        vc.didSignUpSuccess = { [weak self] (userName) in
            if let strongSelf = self {
                strongSelf.signUserName = userName
            }
        }
        present(vc, animated: false)
    }
    
    @IBAction func signInButtonPressed() {
        signIn()
    }
    
    @IBAction func findPasswordButtonPressed() {
    }
}

// MARK:- Methods
extension UserSignInViewController {
    private func translateStrings() {
        setCommonLocalizedString(with: signUpButton, key: CommonLocalizedKey.signUp)
        setCommonLocalizedString(with: signInButton, key: CommonLocalizedKey.signIn)
        setCommonLocalizedString(with: findPasswordButton, key: CommonLocalizedKey.findPassword)
    }
    
    private func userNameError() -> Bool {
        let isEmail = userName.isEmail()
        return (userName.count > 30 || userName.isEmpty || !isEmail)
    }
    
    private func passwordError() -> Bool {
        return (password.count < 6 || password.count > 20 || password.isEmpty)
    }
    
    private func signIn() {
        let loading = LoadingView.view()
        
        if false == userNameError(), false == passwordError() {
            view.endEditing(true)
            
            loading.show()
            let restore = (signUserName != userName)
            signInAndRestoreData(loading: loading, restore: restore)
        } else {
            let message = commonLocalizedString(with: CommonLocalizedKey.checkInput)
            loading.show(with: message, style: .error)
        }
    }
    
    private func signInAndRestoreData(loading: LoadingView, restore: Bool) {
        signIn(loading: loading) { [weak self] (success) in
            if let strongSelf = self {
                if success {
                    if restore {
                        strongSelf.restoreData(loading: loading) { (success) in
                            if success {
                                strongSelf.dismiss(animated: true)
                            }
                        }
                    } else {
                        loading.dismiss()
                        strongSelf.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    private func signIn(loading: LoadingView, completion: ((Bool) -> ())?) {
        LCUser.logIn(username: userName, password: password) { [weak self] (result) in
            if let strongSelf = self {
                if result.isSuccess {
                    strongSelf.signInSuccess()
                    if let _ = completion {
                        completion?(true)
                    } else {
                        loading.dismiss()
                        strongSelf.dismiss(animated: true)
                    }
                } else {
                    strongSelf.alertErrorMessage(loading: loading, error: result.error)
                }
            }
        }
    }
    
    private func restoreData(loading: LoadingView, completion: @escaping (Bool) -> ()) {
        loading.show(with: commonLocalizedString(with: CommonLocalizedKey.syncTips))
        
        let alert = AlertView.view()
        DataManager.restoreData({ [weak self] (success) in
            if let strongSelf = self {
                if false == success {
                    let message = strongSelf.commonLocalizedString(with: CommonLocalizedKey.syncErrorRetry)
                    alert.show(with: message, buttonStyle: .both)
                    alert.didClickButton = { [weak self] (buttonIndex) in
                        alert.dismiss()
                        if let strongSelf = self {
                            if buttonIndex == 1 {
                                strongSelf.restoreData(loading: loading, completion: completion)
                            } else {
                                strongSelf.dismiss(animated: true)
                                loading.dismiss()
                            }
                        }
                    }
                } else {
                    loading.dismiss()
                    completion(true)
                }
            }
        })
    }
    
    private func signInSuccess() {
        UserDefaults.UserInfo.setString(.userName, userName)
        UserDefaults.UserInfo.setString(.password, password)
        didChangeUserState?()
    }
    
    private func alertErrorMessage(loading: LoadingView, error: LCError?) {
        guard let code = error?.code else {
            return
        }
        
        var message: String?
        switch code {
        case 210, 211:
            message = localizedString(with: LocalizedKey.namePasswordError)
            break
        case 219:
            message = localizedString(with: LocalizedKey.retryLater)
            break
        default:
            message = commonLocalizedString(with: CommonLocalizedKey.errorRetry)
            break
        }
        
        if let m = message {
            ErrorManager.reportError(code: .signInFail, message: message ?? "")
            loading.show(with: m, style: .error)
        }
    }
}

// MARK:- UITextFieldDelegate
extension UserSignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if userNameTextField == textField, !userName.isEmpty {
            passwordTextField.becomeFirstResponder()
        } else if passwordTextField == textField, !password.isEmpty {
            view.endEditing(true)
            signIn()
        }
        return true
    }
}
