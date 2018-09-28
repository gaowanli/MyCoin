//
//  ViewAssetViewController.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/9.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit
import SafariServices

private struct LocalizedKey {
    static let title = "Title"
    static let subTitle = "SubTitle"
    static let subMessage = "SubMessage"
    static let deleteTips = "DeleteTips"
    static let deleteRecordTips = "DeleteRecordTips"
}

class ViewAssetViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableHeaderView: ViewCoinHeaderView!
    @IBOutlet private weak var navViewHeight: NSLayoutConstraint!
    
    var collectionId: Int32?
    var coin: CollectionCoin?
    var price: CoinPrice?
    var currencySymbol: String = ""
    
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
        
        if let _ = price {
            let frame = CGRect(origin: .zero, size: CGSize(width: Constant.screenWidth, height: 204.0))
            tableHeaderView.frame = frame
        } else {
            let frame = CGRect(origin: .zero, size: CGSize(width: Constant.screenWidth, height: 78.0))
            tableHeaderView.frame = frame
        }
        tableView.tableHeaderView = tableHeaderView
    }
    
    deinit {
        print("deinit \(type(of: self))")
    }
}

// MARK:- Methods
extension ViewAssetViewController {
    private func setup() {
        tableView.tableHeaderView = tableHeaderView
        tableView.registerNibCell(with: BuyRecordCell.self)
        tableHeaderView.currencySymbol = currencySymbol
        tableHeaderView.data = (coin, price)
        tableHeaderView.didClickLinkButton = { [weak self] (name) in
            if let strongSelf = self {
                strongSelf.openCoinmarketcapUrl(name: name)
            }
        }
        if nil == coin {
            deleteButton.isHidden = true
            addButton.isHidden = true
            loadCoinsDataIfNeed()
        }
    }
    
    private func translateStrings() {
        setLocalizedString(with: titleLabel, key: LocalizedKey.title)
    }
    
    private func loadCoinsDataIfNeed() {
        if let id = collectionId, let symbol = price?.symbol, let name = price?.name {
            let coins = CollectionCoin.coins(by: symbol, andName: name).0
            let num = CollectionCoin.coins(by: symbol, andName: name).1
            coin = CollectionCoin(collectionId: id, symbol: symbol, name: name, num: num, cachePrice: nil, coins: coins)
            tableView.reloadData()
        }
    }
    
    private func showDeleteRecordAlert(coin: Coin?) {
        guard let aCoin = coin else {
            return
        }
        
        let alert = AlertView.view()
        alert.show(with: localizedString(with: LocalizedKey.deleteRecordTips), buttonStyle: .both)
        alert.didClickButton = { [weak self] (index) in
            // 删除
            if let strongSelf = self, index == 1 {
                MyCoin.deleteCoin(byId: aCoin.id)
                
                if let symbol = strongSelf.coin?.symbol, let name = strongSelf.coin?.name {
                    strongSelf.coin?.coins = CollectionCoin.coins(by: symbol, andName: name).0
                    strongSelf.tableHeaderView.data = (strongSelf.coin, strongSelf.price)
                    strongSelf.tableView.reloadData()
                }
            }
        }
    }
    
    private func showNumSubAlert(coin: Coin?) {
        guard let aCoin = coin else {
            return
        }
        
        let title = localizedString(with: LocalizedKey.subTitle)
        let message = localizedString(with: LocalizedKey.subMessage)
        let alert = InputAlertView.view()
        alert.show(with: title, message: message, number: aCoin.num)
        alert.didValidNumber = { [weak self] (num) in
            if let strongSelf = self {
                strongSelf.subCoinNum(aCoin: aCoin, num: num)
            }
        }
    }
    
    private func subCoinNum(aCoin: Coin, num: Double) {
        let toNumString = String(format: "%.6f", aCoin.num - num)
        let toNum = toNumString.decimalValue()
        
        var success = false
        if toNum <= 0 {
            MyCoin.deleteCoin(byId: aCoin.objectID)
            success = true
        } else {
            success = MyCoin.updateCoin(id: aCoin.objectID, num: toNum)
        }
        if success {
            if let symbol = coin?.symbol, let name = coin?.name {
                coin?.coins = CollectionCoin.coins(by: symbol, andName: name).0
                tableHeaderView.data = (coin, price)
                tableView.reloadData()
            }
        } else {
            let loading = LoadingView.view()
            let message = commonLocalizedString(with: CommonLocalizedKey.errorRetry)
            loading.show(with: message, style: .error)
        }
    }
    
    private func openCoinmarketcapUrl(name: String?) {
        guard let n = name, let url = NSURL(string: Coinmarketcap.currenciesUrl + n) as URL? else {
            return
        }
        
        let safariViewController = SFSafariViewController(url: url, entersReaderIfAvailable: true)
        safariViewController.preferredBarTintColor = .yellowTintColor
        navigationController?.pushViewController(safariViewController, animated: true)
    }
}

// MARK:- Events
extension ViewAssetViewController {
    @IBAction func addButtonPressed() {
        if let symbol = coin?.symbol, let name = coin?.name {
            let vc = UIStoryboard.load(from: .main, withId: .editAsset) as! EditAssetViewController
            vc.editMode = .targetedAdd
            vc.coinSymbol = symbol
            vc.coinName = name
            vc.didChangeInputValue = { [weak self] in
                if let strongSelf = self {
                    strongSelf.coin?.coins = CollectionCoin.coins(by: symbol, andName: name).0
                    strongSelf.tableHeaderView.data = (strongSelf.coin, strongSelf.price)
                    strongSelf.tableView.reloadData() 
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteButtonPressed() {
        let alert = AlertView.view()
        alert.show(with: localizedString(with: LocalizedKey.deleteTips), buttonStyle: .both)
        alert.didClickButton = { [weak self] (index) in
            // 删除
            if let strongSelf = self, index == 1, let id = strongSelf.collectionId {
                MyCollection.deleteCollection(byId: id)
                let loading = LoadingView.view()
                let message = strongSelf.commonLocalizedString(with: CommonLocalizedKey.deleteSuccess)
                loading.show(with: message, style: .success)
                strongSelf.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension ViewAssetViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coin?.coins?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableNibCell(with: BuyRecordCell.self) as! BuyRecordCell
        
        let count = coin?.coins?.count ?? 0
        let last = (indexPath.row == count - 1)
        cell.isLastRow = last
        cell.coin = coin?.coins?[indexPath.row]
        cell.didClickSubButton = { [weak self] coin in
            if let strongSelf = self {
                strongSelf.showNumSubAlert(coin: coin)
            }
        }
        cell.didClickDeleteButton = { [weak self] coin in
            if let strongSelf = self {
                strongSelf.showDeleteRecordAlert(coin: coin)
            }
        }
        
        return cell
    }
}

extension ViewAssetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let c = coin?.coins?[indexPath.row] {
            var height: CGFloat = 0.0
            let padding: CGFloat = 10.0
            let titleHeight: CGFloat = 17.0
            let buyDateHeight: CGFloat = 33.0
            var remarksHeight: CGFloat = 0.0
            
            height = height + titleHeight
            if let d = c.buyDate, !d.isEmpty {
                height = height + buyDateHeight
            }
            
            let count = coin?.coins?.count ?? 0
            let last = (indexPath.row == count - 1)
            if let remarks = c.remarks, !remarks.isEmpty {
                let maxWidth = Constant.screenWidth - 44.0
                let font: UIFont = .systemFont(ofSize: 12.0)
                remarksHeight = remarks.height(byFont: font, andMaxWidth: maxWidth) + 18.5
            }
            
            height = height + remarksHeight + 4 * padding
            height = (last ? height : height - padding)
            return height
        } else {
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cs = coin?.coins, let symbol = coin?.symbol, let name = coin?.name {
            let c = cs[indexPath.row]
            
            let vc = UIStoryboard.load(from: .main, withId: .editAsset) as! EditAssetViewController
            vc.editMode = .edit
            vc.coinId = c.objectID
            vc.coinName = c.name ?? ""
            vc.coinSymbol = c.symbol ?? ""
            vc.coinNum = c.num
            vc.isTotalPrice = c.priceIsTotal
            vc.coinPrice = "\(c.price)"
            vc.priceCurrency = c.currency ?? ""
            vc.buyDateString = c.buyDate ?? ""
            vc.isWallet = c.resideIsWallet
            vc.reside = c.reside ?? ""
            vc.remarks = c.remarks
            vc.didChangeInputValue = { [weak self] in
                if let strongSelf = self {
                    strongSelf.coin?.coins = CollectionCoin.coins(by: symbol, andName: name).0
                    strongSelf.tableHeaderView.data = (strongSelf.coin, strongSelf.price)
                    strongSelf.tableView.reloadData()
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
