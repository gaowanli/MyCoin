//
//  WalletViewController.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/7.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

private struct LocalizedKey {
    static let tipsTitle = "TipsTitle"
    static let hotTitle = "HotTitle"
}

class WalletViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var navViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var tipsView: UIView!
    @IBOutlet private weak var tipsLabel: UILabel!
    
    var isSelectMode: Bool = false
    var didChoseResult: ((Wallet?, String?) -> ())?
    private var allWallets: [Wallet] = MyWallet.allWallets() {
        didSet {
            tipsView.isHidden = (allWallets.count > 0)
        }
    }
    private lazy var defaultWallets: [String] = {
        return ["imToken", "MyEtherWallet"]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        translateStrings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if false == isSelectMode {
            tableView.isEditing = true
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if UIDevice.displayNotched {
            navViewHeight.constant = 88.0
        }
    }
    
    deinit {
        print("deinit \(type(of: self))")
    }
}

// MARK:- Events
extension WalletViewController {
    @IBAction func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButtonPressed() {
        let vc = UIStoryboard.load(from: .main, withId: .editWallet) as! EditWalletViewController
        vc.didChangeInputValue = { [weak self] in
            if let strongSelf = self {
                strongSelf.allWallets = MyWallet.allWallets()
                strongSelf.tableView.reloadData()
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK:- Methods
extension WalletViewController {
    private func setup() {
        tableView.tableFooterView = UIView()
        tableView.registerNibCell(with: ItemCell.self)
        tableView.registerNibHeaderFooter(with: GroupHeaderView.self)
        tipsView.isHidden = (isSelectMode ? true : (allWallets.count > 0))
    }
    
    private func translateStrings() {
        setCommonLocalizedString(with: titleLabel, key: CommonLocalizedKey.myWallet)
        setLocalizedString(with: tipsLabel, key: LocalizedKey.tipsTitle)
    }
    
    private func isDisplayDefalutDatas() -> Bool {
        let count = allWallets.count
        return isSelectMode && count == 0
    }
}

extension WalletViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if isSelectMode {
            return 1
        } else {
            return (allWallets.count > 0) ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isDisplayDefalutDatas() {
            return defaultWallets.count
        } else {
            return allWallets.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableNibCell(with: ItemCell.self) as! ItemCell
        
        if isDisplayDefalutDatas() {
            let wallet = defaultWallets[indexPath.row]
            cell.title = wallet
        } else {
            let wallet = allWallets[indexPath.row]
            cell.title = wallet.name ?? ""
        }
        if isSelectMode {
            cell.accessory = false
        }
       
        let rowCount = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        if indexPath.row == rowCount - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: cell.bounds.size.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 0.0)
        }
        
        return cell
    }
}

extension WalletViewController: UITableViewDelegate {
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
        if isDisplayDefalutDatas() {
            view.title = localizedString(with: LocalizedKey.hotTitle)
        } else {
            view.title = commonLocalizedString(with: CommonLocalizedKey.myWallet)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (false == isSelectMode)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return (isSelectMode ? .none : .delete)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return commonLocalizedString(with: CommonLocalizedKey.delete)
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return isSelectMode
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let wallet = allWallets[indexPath.row]
            MyWallet.deleteWallet(byId: wallet.objectID)
            
            allWallets = MyWallet.allWallets()
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isSelectMode {
            if isDisplayDefalutDatas() {
                let wallet = defaultWallets[indexPath.row]
                didChoseResult?(nil, wallet)
            } else {
                let wallet = allWallets[indexPath.row]
                didChoseResult?(wallet, nil)
            }
            navigationController?.popViewController(animated: true)
        } else {
            let wallet = allWallets[indexPath.row]
            let vc = UIStoryboard.load(from: .main, withId: .editWallet) as! EditWalletViewController
            vc.editMode = .edit
            vc.walletId = wallet.objectID
            vc.walletName = wallet.name
            vc.walletAddress = wallet.remarks
            vc.didChangeInputValue = { [weak self] in
                if let strongSelf = self {
                    strongSelf.allWallets = MyWallet.allWallets()
                    strongSelf.tableView.reloadData()
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
