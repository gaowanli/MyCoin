//
//  EditAssetViewController.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/5.
//  Copyright © 2017年 wl. All rights reserved.
//  

import UIKit
import CoreData

private struct LocalizedKey {
    static let addTitle = "AddTitle"
    static let editTitle = "EditTitle"
    static let symbol = "Symbol"
    static let num = "Num"
    static let price = "Price"
    static let wOrE = "WalletOrExchange"
    static let buyDate = "BuyDate"
    static let remarks = "Remarks"
    static let deleteTips = "DeleteTips"
    static let numPlaceholder = "NumPlaceholder"
}

class EditAssetViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var navViewHeight: NSLayoutConstraint!
    
    var coinId: NSManagedObjectID?
    var editMode: PageEditMode = .add
    var coinName: String = ""       // 名称
    var coinSymbol: String = ""     // 符号
    var coinNum: Double = 0.00      // 数量
    var isTotalPrice: Bool = false  // 是否为总价 默认单价
    var coinPrice: String = ""      // 价格
    var priceCurrency: String = ""  // 货币符号
    var buyDateString: String = ""  // 购买日期
    var isWallet: Bool = false      // 是否存放于钱包 默认市场
    var reside: String = ""         // 交易所or钱包
    var remarks: String?            // 备注信息
    var didChangeInputValue: (() -> ())?
    private var coinPriceNull: Bool = true  // 价格为空
    private var buyDateNull: Bool = true    // 购买日为空
    private var valid = false
    
    private lazy var sectionTitles: [String] = {
        let symbol = localizedString(with: LocalizedKey.symbol)
        let num = localizedString(with: LocalizedKey.num)
        let price = localizedString(with: LocalizedKey.price)
        let wOrE = localizedString(with: LocalizedKey.wOrE)
        let buyDate = localizedString(with: LocalizedKey.buyDate)
        let remarks = localizedString(with: LocalizedKey.remarks)
        return [symbol, num, price, wOrE, buyDate, remarks]
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
extension EditAssetViewController {
    @IBAction func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed() {
        valid = true
        tableView.reloadData()
        saveCoinInfo()
    }
    
    @IBAction func deleteButtonPressed() {
        let alert = AlertView.view()
        let message = localizedString(with: LocalizedKey.deleteTips)
        alert.show(with: message, buttonStyle: .both)
        alert.didClickButton = { [weak self] (index) in
            guard let `self` = self else { return }
            
            if index == 1, let id = self.coinId {
                MyCoin.deleteCoin(byId: id)
                let loading = LoadingView.view()
                let message = self.commonLocalizedString(with: CommonLocalizedKey.deleteSuccess)
                loading.show(with: message, style: .success)
                self.didChangeInputValue?()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

// MARK:- Methods
extension EditAssetViewController {
    private func setup() {
        deleteButton.isHidden = (editMode == .add)
        tableView.registerNibCell(with: CoinTagCell.self)
        tableView.registerNibCell(with: TextFieldCell.self)
        tableView.registerNibCell(with: PriceInputCell.self)
        tableView.registerNibCell(with: DateInputCell.self)
        tableView.registerNibCell(with: CoinResideCell.self)
        tableView.registerNibCell(with: TextViewCell.self)
        tableView.registerNibHeaderFooter(with: GroupHeaderView.self)
        tableView.keyboardDismissMode = .onDrag
        if priceCurrency.isEmpty {
            priceCurrency = UserDefaults.Settings.stringValue(.currency)
        }
    }
    
    private func translateStrings() {
        if editMode == .edit {
            titleLabel.text = localizedString(with: LocalizedKey.editTitle)
        } else {
            titleLabel.text = localizedString(with: LocalizedKey.addTitle)
        }
    }
    
    private func coinSymbolError() -> Bool {
        return coinSymbol.isEmpty
    }
    
    private func coinNumError() -> Bool {
        return abs(coinNum) < Constant.minNumber
    }
    
    private func coinPriceError() -> Bool {
        let price = coinPrice.decimalValue()
        return coinPriceNull ? false : (price < Constant.minNumber)
    }
    
    private func buyDateError() -> Bool {
        return buyDateNull ? false : !buyDateString.isDate()
    }
    
    private func remarksError() -> Bool {
        if let r = remarks {
            return (r.count > 100)
        } else {
            return false
        }
    }
    
    private func saveCoinInfo() {
        let loading = LoadingView.view()
        
        if false == coinSymbolError(), false == coinNumError(), false == coinPriceError(), false == buyDateError(), false == remarksError() {
            if editMode != .edit, buyDateString.isEmpty {
                buyDateString = Date.dateString()
            }
            
            var success = false
            if let id = coinId {
                success = MyCoin.updateCoin(id: id, name: coinName, symbol: coinSymbol, num: coinNum, priceIsTotal: isTotalPrice, price: coinPrice.decimalValue(), currency: priceCurrency, resideIsWallet: isWallet, reside: reside, buyDate: buyDateString, remarks: remarks)
            } else {
                success = MyCoin.addCoin(name: coinName, symbol: coinSymbol, num: coinNum, priceIsTotal: isTotalPrice, price: coinPrice.decimalValue(), currency: priceCurrency, resideIsWallet: isWallet, reside: reside, buyDate: buyDateString, remarks: remarks)
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

extension EditAssetViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = tableView.dequeueReusableNibCell(with: CoinTagCell.self) as! CoinTagCell
            cell.tagText = coinSymbol
            cell.error = (valid ? coinSymbolError() : false)
            return cell
        case (1, 0):
            let cell = tableView.dequeueReusableNibCell(with: TextFieldCell.self) as! TextFieldCell
            cell.placeholder = localizedString(with: LocalizedKey.numPlaceholder)
            cell.stringValue = abs(coinNum).trueDecimalString()
            cell.error = (valid ? coinNumError() : false)
            cell.didChangeInputValue = { [weak self] (value) in
                guard let `self` = self else { return }
                
                if let v = value {
                    self.coinNum = v.decimalValue()
                }
            }
            return cell
        case (2, 0):
            let cell = tableView.dequeueReusableNibCell(with: PriceInputCell.self) as! PriceInputCell
            cell.price = coinPrice.decimalValue()
            cell.currency = priceCurrency
            cell.error = (valid ? coinPriceError() : false)
            cell.isTotalPrice = isTotalPrice
            cell.didChangeInputValue = { [weak self] (value) in
                guard let `self` = self else { return }
                
                if let v = value {
                    self.coinPrice = v
                    self.coinPriceNull = v.isEmpty
                } else {
                    self.coinPrice = ""
                    self.coinPriceNull = true
                }
            }
            cell.didChangeSegmentedControlSelected = { [weak self] isTotalPrice in
                guard let `self` = self else { return }
                
                self.isTotalPrice = isTotalPrice
                self.tableView.reloadData()
            }
            return cell
        case (3, 0):
            let cell = tableView.dequeueReusableNibCell(with: CoinResideCell.self) as! CoinResideCell
            cell.tagText = reside
            cell.isWallet = isWallet
            cell.didChangeSegmentedControlSelected = { [weak self] isWallet in
                guard let `self` = self else { return }
                
                if isWallet != self.isWallet {
                    self.reside = ""
                    self.tableView.reloadData()
                }
                self.isWallet = isWallet
            }
            return cell
        case (4, 0):
            let cell = tableView.dequeueReusableNibCell(with: DateInputCell.self) as! DateInputCell
            cell.dateString = buyDateString
            cell.error = (valid ? buyDateError() : false)
            cell.didChangeInputValue = { [weak self] (year, month, day) in
                guard let `self` = self else { return }
                
                if day.isEmpty, month.isEmpty, year.isEmpty {
                    self.buyDateNull = true
                } else {
                    self.buyDateNull = false
                }
                self.buyDateString = "\(year).\(month).\(day)"
            }
            return cell
        case (5, 0):
            let cell = tableView.dequeueReusableNibCell(with: TextViewCell.self) as! TextViewCell
            cell.value = remarks
            cell.error = (valid ? remarksError() : false)
            cell.didChangeInputValue = { [weak self] (value) in
                guard let `self` = self else { return }
                
                self.remarks = value
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension EditAssetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.section == 5 ? 85.0 : 55.0)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooter(with: GroupHeaderView.self) as! GroupHeaderView
        let title = sectionTitles[section]
        view.title = title
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == sectionTitles.count - 1 {
            return 13.0
        } else {
            return 0.0001
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            guard editMode == .add else {
                return
            }
            let vc = UIStoryboard.load(from: .main, withId: .search) as! SearchViewController
            vc.didChoseResult = { [weak self] dict in
                guard let `self` = self else { return }
                
                self.coinName = dict["name"] as! String
                self.coinSymbol = dict["symbol"] as! String
                self.tableView.reloadData()
            }
            present(vc, animated: true)
        case (2, 0):
            let vc = UIStoryboard.load(from: .main, withId: .currency) as! CurrencyViewController
            vc.isSelectMode = true
            vc.didChoseResult = { [weak self] currency in
                guard let `self` = self else { return }
                
                self.priceCurrency = currency
                self.tableView.reloadData()
            }
            navigationController?.pushViewController(vc, animated: true)
        case (3, 0):
            if isWallet {
                let vc = UIStoryboard.load(from: .main, withId: .wallet) as! WalletViewController
                vc.isSelectMode = true
                vc.didChoseResult = { [weak self] (obj, str) in
                    guard let `self` = self else { return }
                    
                    if let wallet = obj {
                        self.reside = wallet.name ?? ""
                    } else if let name = str  {
                        self.reside = name
                    }
                    self.tableView.reloadData()
                }
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = UIStoryboard.load(from: .main, withId: .exchange) as! ExchangeController
                vc.isSelectMode = true
                vc.didChoseResult = { [weak self] (obj, str) in
                    guard let `self` = self else { return }
                    
                    if let exchange = obj {
                        self.reside = exchange.name ?? ""
                    } else if let name = str  {
                        self.reside = name
                    }
                    self.tableView.reloadData()
                }
                navigationController?.pushViewController(vc, animated: true)
            }
        default:
            break
        }
    }
}
