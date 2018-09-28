//
//  EditWalletViewController.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/6.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit
import CoreData

private struct LocalizedKey {
    static let name = "Name"
    static let remarks = "Remarks"
    static let addTitle = "AddTitle"
    static let editTitle = "EditTitle"
    static let namePlaceholder = "NamePlaceholder"
}

class EditWalletViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var footerView: UIView!
    @IBOutlet private weak var footerViewButton: UIButton!
    @IBOutlet private weak var navViewHeight: NSLayoutConstraint!
    
    private var valid = false
    var editMode: PageEditMode = .add
    var walletId: NSManagedObjectID?
    var walletName: String! = ""
    var walletAddress: String?
    var didChangeInputValue: (() -> ())?
    
    private lazy var sectionTitles: [String] = {
        let name = localizedString(with: LocalizedKey.name)
        let remarks = localizedString(with: LocalizedKey.remarks)
        return [name, remarks]
    }()
    
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
        tableView.tableFooterView?.frame = CGRect(x: 0.0, y: 0.0, width: Constant.screenWidth, height: 95.0)
        tableView.tableFooterView = footerView
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
extension EditWalletViewController {
    @IBAction func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed() {
        valid = true
        tableView.reloadData()
        saveWalletInfo()
    }
}

// MARK:- Methods
extension EditWalletViewController {
    private func setup() {
        tableView.tableFooterView = footerView
        tableView.registerNibCell(with: TextFieldCell.self)
        tableView.registerNibCell(with: TextViewCell.self)
        tableView.registerNibHeaderFooter(with: GroupHeaderView.self)
        tableView.keyboardDismissMode = .onDrag
    }
    
    private func translateStrings() {
        if editMode == .add {
            titleLabel.text = localizedString(with: LocalizedKey.addTitle)
        } else {
            titleLabel.text = localizedString(with: LocalizedKey.editTitle)
        }
        setCommonLocalizedString(with: footerViewButton, key: CommonLocalizedKey.save)
    }
    
    private func walletNameError() -> Bool {
        return (walletName.count > 10 || walletName.isEmpty)
    }
    
    private func walletAddressError() -> Bool {
        if let address = walletAddress {
            return address.count > 100
        } else {
            return false
        }
    }
    
    private func saveWalletInfo() {
        let loading = LoadingView.view()
        
        if false == walletNameError(), false == walletAddressError() {
            var success = false
            
            if let id = walletId {
                success = MyWallet.updateWallet(name: walletName, remarks: walletAddress, byId: id)
            } else {
                success = MyWallet.addWallet(name: walletName, remarks: walletAddress)
            }
            
            if success {
                didChangeInputValue?()
                navigationController?.popViewController(animated: true)
            } else {
                let message = commonLocalizedString(with: CommonLocalizedKey.errorRetry)
                loading.show(with: message, style: .error)
            }
        } else {
            let message = commonLocalizedString(with: CommonLocalizedKey.checkInput)
            loading.show(with: message, style: .error)
        }
    }
}

extension EditWalletViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section) {
        case 0:
            let cell = tableView.dequeueReusableNibCell(with: TextFieldCell.self) as! TextFieldCell
            cell.placeholder = localizedString(with: LocalizedKey.namePlaceholder)
            cell.inputString = true
            cell.stringValue = walletName
            cell.error = (valid ? walletNameError() : false)
            cell.didChangeInputValue = { [weak self] (value) in
                if let strongSelf = self, let v = value {
                    strongSelf.walletName = v
                }
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableNibCell(with: TextViewCell.self) as! TextViewCell
            cell.value = walletAddress
            cell.error = (valid ? walletAddressError() : false)
            cell.didChangeInputValue = { [weak self] (value) in
                if let strongSelf = self, let v = value {
                    strongSelf.walletAddress = v
                }
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension EditWalletViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.section == 1 ? 85.0 : 55.0)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooter(with: GroupHeaderView.self) as! GroupHeaderView
        view.title = sectionTitles[section]
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
}
