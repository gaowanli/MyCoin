//
//  CollectionViewController.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/10/30.
//  Copyright © 2017年 wl. All rights reserved.
//  

import UIKit

private struct LocalizedKey {
    static let headerTitle = "headerTitle"
    static let noDataTips = "NoDataTips"
    static let existing = "Existing"
    static let contain = "Contain"
    static let unContain = "UnContain"
}

class CollectionViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var headerTitleLabel: UILabel!
    @IBOutlet private weak var tableHeaderView: UIView!
    @IBOutlet private weak var tipsView: UIView!
    @IBOutlet private weak var noDataTipsLabel: UILabel!
    @IBOutlet private weak var navViewHeight: NSLayoutConstraint!
    
    private var visibleCollections: [Collection] = MyCollection.visibleCollections() {
        didSet {
            tipsView.isHidden = (invisibleCollections.count > 0 || visibleCollections.count > 0)
        }
    }
    private var invisibleCollections: [Collection] = MyCollection.invisibleCollections() {
        didSet {
            tipsView.isHidden = (invisibleCollections.count > 0 || visibleCollections.count > 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        translateStrings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.isEditing = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if UIDevice.displayNotched {
            navViewHeight.constant = 88.0
        }
        
        if invisibleCollections.count > 0 || visibleCollections.count > 0 { // 只要有数据 就显示
            let frame = CGRect(x: 0.0, y: 0.0, width: Constant.screenWidth, height: 33.0)
            tableHeaderView.frame = frame
            tableView.tableHeaderView = tableHeaderView
        } else {
            tableView.tableHeaderView = UIView()
        }
    }
    
    deinit {
        print("deinit \(type(of: self))")
    }
}

// MARK:- Events
extension CollectionViewController {
    @IBAction func searchButtonPressed() {
        goSearchCoin()
    }
    
    @IBAction func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK:- Methods
extension CollectionViewController {
    private func setup() {
        tableView.tableHeaderView = tableHeaderView
        tableView.registerNibCell(with: CoinInfoCell.self)
        tableView.registerNibHeaderFooter(with: GroupHeaderView.self)
        tableView.rowHeight = 67.0
        tipsView.isHidden = (invisibleCollections.count > 0 || visibleCollections.count > 0)
    }
    
    private func translateStrings() {
        setCommonLocalizedString(with: titleLabel, key: CommonLocalizedKey.collection)
        setLocalizedString(with: headerTitleLabel, key: LocalizedKey.headerTitle)
        setLocalizedString(with: noDataTipsLabel, key: LocalizedKey.noDataTips)
    }
    
    private func goSearchCoin() {
        let vc = UIStoryboard.load(from: .main, withId: .search) as! SearchViewController
        vc.didChoseResult = { [weak self] dict in
            if let strongSelf = self {
                let symbol = dict["symbol"] as? String
                let name = dict["name"] as? String
                let result = MyCollection.addCollection(symbol: symbol, name: name)
                if true == result.0 {
                    if true == result.1 {
                        let loading = LoadingView.view()
                        loading.show(with: strongSelf.localizedString(with: LocalizedKey.existing), style: .error)
                    } else {
                        strongSelf.reloadData()
                        strongSelf.tableView.reloadData()
                    }
                }
            }
        }
        present(vc, animated: true)
    }
    
    private func reloadData() {
        visibleCollections = MyCollection.visibleCollections()
        invisibleCollections = MyCollection.invisibleCollections()
        view.setNeedsLayout()
        tableView.reloadData()
    }
}

extension CollectionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let v = visibleCollections.count > 0
        let i = invisibleCollections.count > 0
        return (v || i ? 2 : 0) // 只要有数据 就都显示
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return visibleCollections.count
        } else if section == 1 {
            return invisibleCollections.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableNibCell(with: CoinInfoCell.self, indexPath: indexPath) as! CoinInfoCell
        
        let collection = (indexPath.section == 0 ? visibleCollections[indexPath.row] : invisibleCollections[indexPath.row])
        cell.collection = collection
        cell.accessory = false
        cell.selectionStyle = .none
        
        let rowCount = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        if indexPath.row == rowCount - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: cell.bounds.size.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 0.0)
        }
        
        return cell
    }
}

extension CollectionViewController: UITableViewDelegate {
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
        let contain = localizedString(with: LocalizedKey.contain)
        let unContain = localizedString(with: LocalizedKey.unContain)
        view.title = (section == 0 ? contain : unContain)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return commonLocalizedString(with: CommonLocalizedKey.delete)
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var collection: Collection?
        if sourceIndexPath.section == 0 {
            collection = visibleCollections[sourceIndexPath.row]
        } else if sourceIndexPath.section == 1 {
            collection = invisibleCollections[sourceIndexPath.row]
        }
        
        if let c = collection {
            if sourceIndexPath.section == destinationIndexPath.section {
                // 排序
                let _ = MyCollection.sortCollection(id: c.objectID, toIndex: Int16(destinationIndexPath.row) + 1)
                reloadData()
            } else {
                // 可见or不可见
                let _ = MyCollection.updateCollectionVisible(id: c.objectID)
                reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 删除
            var collection: Collection?
            if indexPath.section == 0 {
                collection = visibleCollections[indexPath.row]
            } else if indexPath.section == 1 {
                collection = invisibleCollections[indexPath.row]
            }
            
            if let c = collection {
                MyCollection.deleteCollection(byId: c.objectID)
                reloadData()
            }
        }
    }
}
