//
//  MessageDetailViewController.swift
//  MyCoin
//
//  Created by GaoWanli on 17/01/2018.
//  Copyright © 2018 wl. All rights reserved.
//

import UIKit
import LeanCloud

private struct LocalizedKey {
    static let title = "TitleLabel"
}

class MessageDetailViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageTitleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var navViewHeight: NSLayoutConstraint!

    var message: LCObject?
    
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
extension MessageDetailViewController {
    @IBAction func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK:- Methods
extension MessageDetailViewController {
    private func setup() {
        guard let m = message else {
            return
        }
        
        let cn = (Language.current == .chinese)
        var title = ""
        let titleCN = m.get(MessageClass.title.column)?.stringValue ?? ""
        let titleEN = m.get(MessageClass.titleEN.column)?.stringValue ?? ""
        var content = ""
        let contentCN = m.get(MessageClass.content.column)?.stringValue ?? ""
        let contentEN = m.get(MessageClass.contentEN.column)?.stringValue ?? ""
        
        title = (cn ? titleCN : titleEN)
        content = (cn ? contentCN : contentEN)
        
        messageTitleLabel.text = title
        contentLabel.text = content
        if let date = m.get(MessageClass.timestamp.column)?.doubleValue {
            dateLabel.text = date.dateString()
        } else {
            dateLabel.text = nil
        }
    }
    
    private func translateStrings() {
        setLocalizedString(with: titleLabel, key: LocalizedKey.title)
    }
}
