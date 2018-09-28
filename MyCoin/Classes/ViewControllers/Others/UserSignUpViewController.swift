//
//  UserSignUpViewController.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/16.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit
import LeanCloud

private struct LocalizedKey {
    static let nameExisting = "ErrorNameExisting"
    static let retryLater = "RetryLater"
    static let signUpSuccess = "SignUpSuccess"
}

class UserSignUpViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var signUpButton: UIButton!
    @IBOutlet private weak var userNameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var rPasswordTextField: UITextField!
    @IBOutlet private weak var navViewHeight: NSLayoutConstraint!
    
    var didClickCloseButton: (() -> ())?
    var didSignUpSuccess: ((String) -> ())?
    private var userName: String {
        return self.userNameTextField.text ?? ""
    }
    private var password: String {
        return self.passwordTextField.text ?? ""
    }
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        userNameTextField.becomeFirstResponder()
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
extension UserSignUpViewController {
    @IBAction func closeButtonPressed() {
        didClickCloseButton?()
    }
    
    @IBAction func signUpButtonPressed() {
        signUp()
    }
}

// MARK:- Methods
extension UserSignUpViewController {
    private func translateStrings() {
        setCommonLocalizedString(with: signUpButton, key: CommonLocalizedKey.signUp)
    }
    
    private func userNameError() -> Bool {
        let isEmail = userName.isEmail()
        return (userName.count > 30 || userName.isEmpty || !isEmail)
    }
    
    private func passwordError() -> Bool {
        return (password.count < 6 || password.count > 20 || password.isEmpty)
    }
    
    private func passwordMismatch() -> Bool {
        return (rPasswordTextField.text != password)
    }
    
    private func signUp() {
        let loading = LoadingView.view()
        
        if false == userNameError(), false == passwordError(), false == passwordMismatch() {
            view.endEditing(true)
            
            loading.show()
            signUp(loading: loading)
        } else {
            let message = commonLocalizedString(with: CommonLocalizedKey.checkInput)
            loading.show(with: message, style: .error)
        }
    }
    
    private func signUp(loading: LoadingView) {
        let user = LCUser()
        user.username = LCString(userName)
        user.password = LCString(password)
        user.signUp { [weak self] (result) in
            if let strongSelf = self {
                if result.isSuccess {
                    strongSelf.signUpSuccess(loading: loading)
                } else {
                    loading.dismiss()
                    strongSelf.alertErrorMessage(loading: loading, error: result.error)
                }
            }
        }
    }
    
    private func signUpSuccess(loading: LoadingView) {
        UserDefaults.UserInfo.setString(.userName, userName)
        
        let message = localizedString(with: LocalizedKey.signUpSuccess)
        loading.show(with: message, style: .success)
        didSignUpSuccess?(userName)
        dismiss(animated: false)
    }
    
    private func alertErrorMessage(loading: LoadingView, error: LCError?) {
        guard let code = error?.code else {
            return
        }
        
        var message: String?
        switch code {
        case 202, 203:
            message = localizedString(with: LocalizedKey.nameExisting)
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
extension UserSignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if userNameTextField == textField, !userName.isEmpty {
            passwordTextField.becomeFirstResponder()
        } else if passwordTextField == textField, !password.isEmpty {
            rPasswordTextField.becomeFirstResponder()
        } else if rPasswordTextField == textField, (rPasswordTextField.text?.count ?? 0) > 0 {
            view.endEditing(true)
            signUp()
        }
        return true
    }
}
