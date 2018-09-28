//
//  ExchangeController.swift
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

class ExchangeController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var navViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var tipsView: UIView!
    @IBOutlet private weak var tipsLabel: UILabel!
    
    var isSelectMode: Bool = false
    var didChoseResult: ((Exchange?, String?) -> ())?
    private var allExchanges: [Exchange] = MyExchange.allExchanges() {
        didSet {
            tipsView.isHidden = (allExchanges.count > 0)
        }
    }
    private lazy var defaultExchanges: [String] = {
        return ["Poloniex", "Bittrex", "EtherDelta", "Binance"]
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
extension ExchangeController {
    @IBAction func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButtonPressed() {
        let vc = UIStoryboard.load(from: .main, withId: .editExchange) as! EditExchangeViewController
        vc.didChangeInputValue = { [weak self] in
            if let strongSelf = self {
                strongSelf.allExchanges = MyExchange.allExchanges()
                strongSelf.tableView.reloadData()
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK:- Methods
extension ExchangeController {
    private func setup() {
        tableView.tableFooterView = UIView()
        tableView.registerNibCell(with: ItemCell.self)
        tableView.registerNibHeaderFooter(with: GroupHeaderView.self)
        tipsView.isHidden = (isSelectMode ? true : (allExchanges.count > 0))
    }
    
    private func translateStrings() {
        setCommonLocalizedString(with: titleLabel, key: CommonLocalizedKey.myExchange)
        setLocalizedString(with: tipsLabel, key: LocalizedKey.tipsTitle)
    }
    
    private func isDisplayDefalutDatas() -> Bool {
        let count = allExchanges.count
        return isSelectMode && count == 0
    }
}

extension ExchangeController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if isSelectMode {
            return 1
        } else {
            return (allExchanges.count > 0) ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isDisplayDefalutDatas() {
            return defaultExchanges.count
        } else {
            return allExchanges.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableNibCell(with: ItemCell.self) as! ItemCell
        if isDisplayDefalutDatas() {
            let exchange = defaultExchanges[indexPath.row]
            cell.title = exchange
        } else {
            let exchange = allExchanges[indexPath.row]
            cell.title = exchange.name ?? ""
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

extension ExchangeController: UITableViewDelegate {
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
            view.title = commonLocalizedString(with: CommonLocalizedKey.myExchange)
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
            let exchange = allExchanges[indexPath.row]
            MyExchange.deleteExchange(byId: exchange.objectID)
            
            allExchanges = MyExchange.allExchanges()
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isSelectMode {
            if isDisplayDefalutDatas() {
                let exchange = defaultExchanges[indexPath.row]
                didChoseResult?(nil, exchange)
            } else {
                let exchange = allExchanges[indexPath.row]
                didChoseResult?(exchange, nil)
            }
            navigationController?.popViewController(animated: true)
        } else {
            let exchange = allExchanges[indexPath.row]
            let vc = UIStoryboard.load(from: .main, withId: .editExchange) as! EditExchangeViewController
            vc.editMode = .edit
            vc.exchangeId = exchange.objectID
            vc.exchangeName = exchange.name
            vc.exchangeAddress = exchange.remarks
            vc.didChangeInputValue = { [weak self] in
                if let strongSelf = self {
                    strongSelf.allExchanges = MyExchange.allExchanges()
                    strongSelf.tableView.reloadData()
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
