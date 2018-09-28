//
//  FeedbackViewController.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/12/12.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit
import LeanCloud

private struct LocalizedKey {
    static let tipsTitle = "TipsTitle"
    static let submit = "Submit"
    static let thanks = "Thanks"
    static let characters = "Characters"
}

class FeedbackViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var tipsTitleLabel: UILabel!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var charactersTipsLabel: UILabel!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var navViewHeight: NSLayoutConstraint!
    
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
extension FeedbackViewController {
    @IBAction func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButtonPressed() {
        view.endEditing(true)
        submitFeedbackIfNeed()
    }
}

// MARK:- Methods
extension FeedbackViewController {
    private func setup() {
        scrollView.keyboardDismissMode = .onDrag
    }
    
    private func translateStrings() {
        setCommonLocalizedString(with: titleLabel, key: CommonLocalizedKey.feedback)
        setLocalizedString(with: tipsTitleLabel, key: LocalizedKey.tipsTitle)
        setLocalizedString(with: charactersTipsLabel, key: LocalizedKey.characters)
        setLocalizedString(with: submitButton, key: LocalizedKey.submit)
    }
    
    private func submitFeedbackIfNeed(erorAlert: Bool = true) {
        guard let userId = LCUser.current?.objectId?.stringValue else {
            sign()
            return
        }
        let content = textView.text.trimWhitespaces()
        let characters = content.count
        if characters < 20 {
            if true == erorAlert {
                let loading = LoadingView.view()
                let message = commonLocalizedString(with: CommonLocalizedKey.checkInput)
                loading.show(with: message, style: .error)
            }
            return
        }
        submitFeedback(userId: userId)
    }
    
    private func sign() {
        let vc = UIStoryboard.load(from: .main, withId: .signIn) as! UserSignInViewController
        vc.didChangeUserState = { [weak self] in
            if let strongSelf = self {
                strongSelf.submitFeedbackIfNeed(erorAlert: false)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func submitFeedback(userId: String) {
        var content = textView.text.trimWhitespaces()
        let characters = content.count
        if characters > 800 {
            let sIndex = content.startIndex
            let eIndex = content.index(sIndex, offsetBy: 800)
            content = String(content[sIndex..<eIndex])
        }
        
        let loading = LoadingView.view()
        loading.show()
        DataManager.addUserFeedback(userId: userId, content: content) { [weak self] (success) in
            if let strongSelf = self {
                if success {
                    let message = strongSelf.localizedString(with: LocalizedKey.thanks)
                    loading.show(with: message, style: .success)
                    strongSelf.navigationController?.popViewController(animated: true)
                } else {
                    let message = strongSelf.commonLocalizedString(with: CommonLocalizedKey.errorRetry)
                    loading.show(with: message, style: .error)
                }
            }
        }
    }
}
