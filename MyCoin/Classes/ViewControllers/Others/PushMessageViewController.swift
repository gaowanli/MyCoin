//
//  PushMessageViewController.swift
//  MyCoin
//
//  Created by GaoWanli on 24/01/2018.
//  Copyright © 2018 wl. All rights reserved.
//

import UIKit

class PushMessageViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleCNTextView: UITextView!
    @IBOutlet private weak var titleENTextView: UITextView!
    @IBOutlet private weak var contentCNTextView: UITextView!
    @IBOutlet private weak var contentENTextView: UITextView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var navViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
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
extension PushMessageViewController {
    @IBAction func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pushButtonPressed() {
        view.endEditing(true)
        
        let loading = LoadingView.view()
        guard let titleCN = titleCNTextView.text, titleCN.count > 10 else {
            loading.show(with: "中文标题必须10个字符以上", style: .error)
            return
        }
        guard let titleEN = titleENTextView.text, titleEN.count > 10 else {
            loading.show(with: "英文标题必须10个字符以上", style: .error)
            return
        }
        guard let contentCN = contentCNTextView.text, contentCN.count > 10 else {
            loading.show(with: "中文内容必须20个字符以上", style: .error)
            return
        }
        guard let contentEN = contentENTextView.text, contentEN.count > 10 else {
            loading.show(with: "英文内容必须20个字符以上", style: .error)
            return
        }
        let toAll = (segmentedControl.selectedSegmentIndex == 1)
                
        loading.show()
        DataManager.pushMessage(title: titleCN, titleEN: titleEN, content: contentCN, contentEN: contentEN, toAll: toAll, completion: { [weak self] (success) in
            if let strongSelf = self {
                if success {
                    loading.dismiss()
                    strongSelf.navigationController?.popViewController(animated: true)
                } else {
                    loading.show(with: "提交失败", style: .error)
                }
            }
        })
    }
}

// MARK:- Methods
extension PushMessageViewController {
    private func setup() {
        scrollView.keyboardDismissMode = .onDrag
    }
}
