//
//  SearchViewController.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/10/31.
//  Copyright © 2017年 wl. All rights reserved.
//  

import UIKit

private struct LocalizedKey {
    static let searchPlaceholder = "SearchPlaceholder"
    static let noResultTips = "NoResultTips"
}

class SearchViewController: UIViewController {
    @IBOutlet private weak var keyTextField: UITextField!
    @IBOutlet private weak var syncButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var noResultView: UIView!
    @IBOutlet private weak var noResultTipsLabel: UILabel!
    @IBOutlet private weak var navViewHeight: NSLayoutConstraint!
    
    var didChoseResult: ((NSDictionary) -> ())?
    private var results: [NSDictionary]?
    private var selectedRow = -1
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        loadAllData()
        translateStrings()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if UIDevice.displayNotched {
            navViewHeight.constant = 88.0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        delay(0.1) {
            self.keyTextField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("deinit \(type(of: self))")
    }
}

// MARK:- Events
extension SearchViewController {
    @IBAction func syncButtonPressed() {
        view.endEditing(true)
        
        let loading = LoadingView.view()
        loading.show()
        
        DataManager.downloadPlistIfNeed { [weak self] (success) in
            if let strongSelf = self {
                if success {
                    loading.dismiss()
                    strongSelf.syncButton.isHidden = true
                    strongSelf.loadAllData()
                } else {
                    let message = strongSelf.commonLocalizedString(with: CommonLocalizedKey.errorRetry)
                    loading.show(with: message, style: .error)
                }
            }
        }
    }
    
    @IBAction func closeButtonPressed() {
        dismiss(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK:- Methods
extension SearchViewController {
    private func setup() {
        syncButton.isHidden = true
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let placeholder = localizedString(with: LocalizedKey.searchPlaceholder)
        let attributedString = NSAttributedString.init(string: placeholder, attributes: attributes)
        keyTextField.attributedPlaceholder = attributedString
        
        tableView.tableFooterView = UIView()
        tableView.registerNibCell(with: CoinInfoCell.self)
        tableView.rowHeight = 67.0
        tableView.isHidden = true
        tableView.keyboardDismissMode = .onDrag
        noResultView.isHidden = true
    }
    
    private func loadAllData() {
        results = Coins.allCoins()
        if let r = results, r.count > 0 {
            showResults()
            
            if r.count < 10 {
                let appleInReview = UserDefaults.Variable.boolValue(.appleInReview)
                syncButton.isHidden = appleInReview
            }
        } else {
            hiddenResults()
        }
    }
    
    private func translateStrings() {
        setLocalizedString(with: noResultTipsLabel, key: LocalizedKey.noResultTips)
    }
    
    private func searchCoinsIfNeed(by key: String?) {
        results = nil
        
        guard let k = key else {
            hiddenResults()
            return
        }
        
        let ke = k.trimWhitespaces()
        if ke.count > 0, ke.count <= 20 {
            results = Coins.searchCoin(by: ke)
            if let r = results, r.count > 0 {
                showResults()
            } else {
                hiddenResults()
            }
        } else {
            hiddenResults()
        }
    }
    
    private func showResults() {
        noResultView.isHidden = true
        tableView.isHidden = false
        tableView.setContentOffset(.zero, animated: true)
        tableView.reloadData()
    }
    
    private func hiddenResults() {
        results = nil
        tableView.reloadData()
        noResultView.isHidden = false
        tableView.isHidden = true
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableNibCell(with: CoinInfoCell.self, indexPath: indexPath) as! CoinInfoCell
        cell.info = results?[indexPath.row]
        cell.accessory = (indexPath.row == selectedRow)
        
        let rowCount = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        if indexPath.row == rowCount - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: cell.bounds.size.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 0.0)
        }
        
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
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
        let view = UIView()
        view.backgroundColor = tableView.backgroundColor
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedRow = indexPath.row
        tableView.reloadData()
        
        let dict = results![indexPath.row]
        didChoseResult?(dict)
        
        dismiss(animated: true)
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        keyTextField.resignFirstResponder()
        searchCoinsIfNeed(by: keyTextField.text)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        loadAllData()
        return true
    }
}
