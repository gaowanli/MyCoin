//
//  CurrencyViewController.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/10/30.
//  Copyright © 2017年 wl. All rights reserved.
//  

import UIKit

private struct LocalizedKey {
    static let current = "Current"
    static let all = "All"
}

class CurrencyViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var navViewHeight: NSLayoutConstraint!
    
    var isSelectMode: Bool = false
    var didChoseResult: ((String) -> ())?
    
    private lazy var allSymbols: [String] = {
        return CurrencySymbol.allSymbolsString()
    }()
    private lazy var selectedRow: Int = {
        let currency = UserDefaults.Settings.stringValue(.currency)
        return allSymbols.index(of: currency) ?? -1
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
    
    deinit {
        print("deinit \(type(of: self))")
    }
}

// MARK:- Events
extension CurrencyViewController {
    @IBAction func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK:- Methods
extension CurrencyViewController {
    private func setup() {
        tableView.tableFooterView = UIView()
        tableView.registerNibCell(with: ItemCell.self)
        tableView.registerNibHeaderFooter(with: GroupHeaderView.self)
    }
    
    private func translateStrings() {
        setCommonLocalizedString(with: titleLabel, key: CommonLocalizedKey.currency)
    }
}

extension CurrencyViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return isSelectMode ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSelectMode {
            return allSymbols.count
        } else {
            return (section == 0 ? 1 : allSymbols.count)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableNibCell(with: ItemCell.self) as! ItemCell
        cell.accessoryIsArrow = false
        
        if false == isSelectMode, indexPath.section == 0 {
            cell.accessory = true
            let currency = UserDefaults.Settings.stringValue(.currency)
            cell.title = currency
        } else {
            cell.accessory = false
            cell.title = allSymbols[indexPath.row]
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

extension CurrencyViewController: UITableViewDelegate {
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
        if isSelectMode {
            view.title = commonLocalizedString(with: CommonLocalizedKey.currency)
        } else {
            let current = localizedString(with: LocalizedKey.current)
            let all = localizedString(with: LocalizedKey.all)
            view.title = (section == 0 ? current : all)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let currency = allSymbols[indexPath.row]
        if isSelectMode {
            didChoseResult?(currency)
        } else {
            if indexPath.section == 1 {
                let old = UserDefaults.Settings.stringValue(.currency)
                if old != currency {
                    UserDefaults.Settings.setString(.currency, currency)
                }
                selectedRow = indexPath.row
                tableView.reloadData()
            }
        }
        navigationController?.popViewController(animated: true)
    }
}
