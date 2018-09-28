//
//  MessageViewController.swift
//  MyCoin
//
//  Created by GaoWanli on 17/01/2018.
//  Copyright © 2018 wl. All rights reserved.
//

import UIKit
import LeanCloud

private struct LocalizedKey {
    static let tipsTitle = "TipsTitle"
    static let title = "TitleLabel"
}

class MessageViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tipsView: UIView!
    @IBOutlet private weak var tipsLabel: UILabel!
    @IBOutlet private weak var navViewHeight: NSLayoutConstraint!
    
    private var messages: [LCObject] = [LCObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        translateStrings()
        fetchData()
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
extension MessageViewController {
    @IBAction func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK:- Methods
extension MessageViewController {
    private func setup() {
        tableView.tableFooterView = UIView()
        tableView.registerNibCell(with: MessageItemCell.self)
        tableView.rowHeight = 64.0
        tableView.registerNibHeaderFooter(with: GroupHeaderView.self)
        tipsView.isHidden = true
    }
    
    private func translateStrings() {
        setLocalizedString(with: titleLabel, key: LocalizedKey.title)
        setLocalizedString(with: tipsLabel, key: LocalizedKey.tipsTitle)
    }
    
    private func fetchData() {
        DataManager.fetchAllMessages { [weak self] (success, result) in
            if let strongSelf = self {
                strongSelf.indicatorView.stopAnimating()
                
                if let r = result {
                    strongSelf.tipsView.isHidden = (r.count > 0)
                    strongSelf.messages = r
                    strongSelf.tableView.reloadData()
                } else {
                    strongSelf.tipsView.isHidden = false
                }
            }
        }
    }
}

extension MessageViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return (messages.count > 0 ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableNibCell(with: MessageItemCell.self) as! MessageItemCell
        cell.message = messages[indexPath.row]
        
        let rowCount = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        if indexPath.row == rowCount - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: cell.bounds.size.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 0.0)
        }
        
        return cell
    }
}

extension MessageViewController: UITableViewDelegate {
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
        view.title = localizedString(with: LocalizedKey.title)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let message = messages[indexPath.row]
        
        if indexPath.row == 0 {
            if let timestamp = message.get(MessageClass.timestamp.column)?.intValue {
                UserDefaults.Variable.setString(.messageTimestamp, "\(timestamp)")
            }
        }
        
        let vc = UIStoryboard.load(from: .main, withId: .messageDetail) as! MessageDetailViewController
        vc.message = message
        navigationController?.pushViewController(vc, animated: true)
    }
}
