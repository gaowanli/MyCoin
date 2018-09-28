//
//  AssetsViewController.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/10/17.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit
import CoreData
import LeanCloud

private struct LocalizedKey {
    static let title = "TitleLabel"
}

class AssetsViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var chartButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var currencySymbolIconLabel: UILabel!
    @IBOutlet private weak var totalPriceLabel: UILabel!
    @IBOutlet private weak var navViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var headerViewHeight: NSLayoutConstraint!
    
    private lazy var refreshControl: UIRefreshControl = {
        let r = UIRefreshControl()
        r.tintColor = .yellowTintColor
        let refreshData = #selector(AssetsViewController.refreshData)
        r.addTarget(self, action: refreshData, for: .valueChanged)
        return r
    }()
    private lazy var generator: UIImpactFeedbackGenerator = {
        let g = UIImpactFeedbackGenerator(style: .medium)
        g.prepare()
        return g
    }()
    private var defaultCoins: [NSDictionary]?
    private var coins: [CollectionCoin] = [] {
        didSet {
            if coins.count == 0 {
                defaultCoins = Coins.defaultCoins()
            } else {
                defaultCoins = nil
            }
        }
    }
    private var coinPrice = [String: CoinPrice?]()
    private var totalPrice: Double = 0.00 {
        didSet {
            chartButton.isHidden = (totalPrice <= 0.00)
        }
    }
    private var currencySymbol: String = CurrencySymbol.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        reloadListData()
        translateStrings()
        downloadPlistIfNeed()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if UIDevice.displayNotched {
            navViewHeight.constant = 88.0
        }
        headerViewHeight.constant = 155.0 * Constant.screenHeight / 568.0
        tableView.bringSubviewToFront(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchPriceData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK:- Events
extension AssetsViewController {
    @objc private func refreshData() {
        generator.impactOccurred()
        fetchPriceData()
    }
    
    @IBAction func addButtonPressed() {
        let vc = UIStoryboard.load(from: .main, withId: .editAsset)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func chartButtonPressed() {
        let vc = UIStoryboard.load(from: .main, withId: .chart) as! ChartViewController
        vc.coins = coins
        vc.coinPrice = coinPrice
        vc.currencySymbol = currencySymbol
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK:- 任务处理
extension AssetsViewController {
    private func setup() {
        chartButton.isUserInteractionEnabled = false
        tableView.tableFooterView = UIView()
        tableView.registerNibCell(with: AssetItemCell.self)
        tableView.rowHeight = 65.0
        tableView.refreshControl = refreshControl
        
        coins = CollectionCoin.allCollectionCoins()
        tableView.reloadData()
        
        if UIScreen.main.traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(AssetsViewController.reloadListData), name: .autoRestoreDataSuccess, object: nil)
    }
    
    private func translateStrings() {
        setLocalizedString(with: titleLabel, key: LocalizedKey.title)
    }
    
    private func downloadPlistIfNeed() {
        DataManager.downloadPlistIfNeed(completion: nil)
    }
}

// MARK:- Methods
extension AssetsViewController {
    /// 请求价格数据
    private func fetchPriceData() {
        chartButton.isUserInteractionEnabled = false
        beginLoadingAnimation()
        coins = CollectionCoin.allCollectionCoins()
        
        let rNum = coins.count
        let dNum = defaultCoins?.count ?? 0
        let num = (rNum == 0 ? dNum : rNum)
        let currency = UserDefaults.Settings.stringValue(.currency)
        
        let group = DispatchGroup()
        for i in 0..<num {
            group.enter()
            
            var symbol = ""
            var name = ""
            if rNum == 0 {
                if let d = defaultCoins {
                    let coin = d[i]
                    name = (coin["name"] as? String) ?? ""
                }
            } else {
                let coin = coins[i]
                symbol = coin.symbol
                name = coin.name
            }
            CoinPrice.fetchPrice(symbol: symbol, name: name, currency: currency.lowercased(), completion: { [weak self] (id, currency, coinPrice, success) in
                guard let `self` = self else { return }
                if true == success, let c = coinPrice {
                    if rNum == 0 {
                        self.coinPrice[c.id] = c
                    } else {
                        self.coinPrice[id] = c
                    }
                    MyPriceCache.addPriceCache(with: symbol, name: name, price: c.price, priceUSD: c.priceUSD, currency: currency, percent1h: c.percent1h, percent24h: c.percent24h, percent7d: c.percent7d)
                }
                group.leave()
            })
        }
        group.notify(queue: DispatchQueue.main) { [weak self] in
            guard let `self` = self else { return }
            self.currencySymbol = CurrencySymbol.current()
            self.chartButton.isUserInteractionEnabled = true
            self.endLoadingAnimation()
            self.reloadListData()
        }
    }
    
    private func beginLoadingAnimation() {
        currencySymbolIconLabel.beginFlicker()
        totalPriceLabel.beginFlicker()
    }
    
    private func endLoadingAnimation() {
        refreshControl.endRefreshing()
        currencySymbolIconLabel.endFlicker()
        totalPriceLabel.endFlicker()
    }
    
    /// 刷新列表配置数据
    @objc func reloadListData() {
        coins = CollectionCoin.allCollectionCoins()
        tableView.reloadData()
        
        reloadTotalPriceData()
    }
    
    /// 刷新总价数据
    private func reloadTotalPriceData() {
        currencySymbolIconLabel.text = currencySymbol.trimWhitespaces()
        
        let haveData = (coins.count > 0)
        if haveData {
            let count = coins.count
            var totalPrice = 0.00 // 总价
            for i in 0..<count {
                let coin = coins[i]
                let num = coin.num
                var price = 0.00
                if let p = coinPrice[coin.symbol] {
                    price = p?.price ?? 0.00
                } else if let c = coin.cachePrice {
                    price = c.price
                }
                totalPrice = totalPrice + price * num
            }
            self.totalPrice = totalPrice
            totalPriceLabel.text = (totalPrice.decimalString() ?? "0.00")
        } else {
            self.totalPrice = 0.00
            totalPriceLabel.text = "0.00"
        }
    }
    
    private func viewCoinController(row: Int) -> ViewAssetViewController? {
        let vc = UIStoryboard.load(from: .main, withId: .viewAsset) as! ViewAssetViewController
        vc.currencySymbol = currencySymbol
        if coins.count > 0 {
            if coins.count <= row {
                return nil
            }
            
            let coin = coins[row]
            vc.coin = coin
            vc.collectionId = coin.collectionId
            if let price = coinPrice[coin.symbol] {
                vc.price = price
            }
        } else {
            if defaultCoins == nil {
                return nil
            }
            
            let coin = defaultCoins![row]
            let name = (coin["name"] as? String) ?? ""
            if let price = coinPrice[name] {
                vc.price = price
            } else {
                return nil
            }
        }
        return vc
    }
}

extension AssetsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if coins.count == 0 {
            return defaultCoins?.count ?? 0
        } else {
            return coins.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableNibCell(with: AssetItemCell.self) as! AssetItemCell
        
        cell.currencySymbol = currencySymbol
        if coins.count == 0 {
            if defaultCoins!.count <= indexPath.section {
                return UITableViewCell()
            }
            
            let coin = defaultCoins![indexPath.section]
            cell.defalutData = coin
            
            let name = (coin["name"] as? String) ?? ""
            if let price = coinPrice[name] {
                cell.price = price
            } else {
                cell.price = nil
            }
        } else {
            if coins.count <= indexPath.section {
                return UITableViewCell()
            }
            
            let coin = coins[indexPath.section]
            cell.coin = coin
            
            if let price = coinPrice[coin.symbol] {
                cell.price = price
            } else {
                cell.price = nil
            }
        }
        
        return cell
    }
}

extension AssetsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        mainThread {
            if let vc = self.viewCoinController(row: indexPath.section) {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4.0
    }
    
}

extension AssetsViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            let vc = viewCoinController(row: indexPath.section)
            return vc
        } else {
            return nil
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}
