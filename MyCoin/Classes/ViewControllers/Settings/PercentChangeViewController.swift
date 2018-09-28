//
//  PercentChangeViewController.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/5.
//  Copyright © 2017年 wl. All rights reserved.
//  

import UIKit

class PercentChangeViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var navViewHeight: NSLayoutConstraint!
    
    private lazy var allPercentString: [(PercentChange, String)] = {
        let oneHour = commonLocalizedString(with: CommonLocalizedKey.oneHour)
        let twentyFourHour = commonLocalizedString(with: CommonLocalizedKey.twentyFourHour)
        let sevenDay = commonLocalizedString(with: CommonLocalizedKey.sevenDay)
        return [(PercentChange.oneHour, oneHour),
                (PercentChange.twentyFourHour, twentyFourHour),
                (PercentChange.sevenDay, sevenDay)]
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
extension PercentChangeViewController {
    @IBAction func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK:- Methods
extension PercentChangeViewController {
    private func setup() {
        tableView.tableFooterView = UIView()
        tableView.registerNibCell(with: ItemCell.self)
        tableView.registerNibHeaderFooter(with: GroupHeaderView.self)
    }
    
    private func translateStrings() {
        setCommonLocalizedString(with: titleLabel, key: CommonLocalizedKey.percentChange)
    }
}

extension PercentChangeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPercentString.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableNibCell(with: ItemCell.self) as! ItemCell
        
        let percentChange = UserDefaults.Settings.stringValue(.percentChange)
        let p = allPercentString[indexPath.row]
        cell.title = p.1
        cell.accessoryIsArrow = false
        cell.accessory = (p.0.rawValue == percentChange)
        
        let rowCount = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        if indexPath.row == rowCount - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: cell.bounds.size.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 0.0)
        }
        
        return cell
    }
}

extension PercentChangeViewController: UITableViewDelegate {
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
        view.title = commonLocalizedString(with: CommonLocalizedKey.percentChange)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let p = allPercentString[indexPath.row]
        
        let old = UserDefaults.Settings.stringValue(.percentChange)
        let new = p.0.rawValue
        if old != new {
            UserDefaults.Settings.setString(.percentChange, new)
        }
        
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
}
