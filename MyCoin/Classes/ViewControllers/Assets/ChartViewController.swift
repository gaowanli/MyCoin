//
//  ChartViewController.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/12/11.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit
import PNChart

private struct LocalizedKey {
    static let title = "Title"
    static let segmentedTitle1 = "SegmentedTitle1"
    static let segmentedTitle2 = "SegmentedTitle2"
    static let unknowns = "Unknowns"
    static let others = "Others"
}

class ChartViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableHeaderView: UIView!
    @IBOutlet private weak var chartContainerView: UIView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var navViewHeight: NSLayoutConstraint!
    
    var coins: [CollectionCoin] = []
    var currencySymbol: String = ""
    var coinPrice = [String: CoinPrice?]()
    private lazy var chartViewFrame: CGRect = {
        let y: CGFloat = 10.0
        let cWidth = Constant.screenWidth - 40.0
        var width: CGFloat = cWidth * 0.8 - 2 * y
        let height = width
        let x: CGFloat = (cWidth - width) * 0.5
        return CGRect(x: x, y: y, width: width, height: height)
    }()
    private lazy var pieChart: PNPieChart = {
        let chart = PNPieChart(frame: chartViewFrame)
        chart.descriptionTextColor = .white
        chart.descriptionTextFont = .systemFont(ofSize: 10.0)
        chart.shouldHighlightSectorOnTouch = true
        chart.showOnlyValues = true
        chart.displayAnimated = true
        chart.duration = 0.5
        chart.delegate = self
        return chart
    }()
    private lazy var chartColors: [UIColor] = {
        let colors: [UIColor] = [.hex(value: 0x636CDA),
                                 .hex(value: 0x536CDA),
                                 .hex(value: 0x8198FF),
                                 .hex(value: 0xA1B2FA),
                                 .hex(value: 0xC2CDFF)
        ]
        return colors
    }()
    private var chartUnknownColor = UIColor.hex(value: 0xFEA200)
    private var chartOtherColor = UIColor.hex(value: 0xF6C773)
    private var moneyChartItems = [PNPieChartDataItem]()
    private var moneyDatas = [(color: UIColor, symbol: String, price: Double)]()
    private var moneyChartSelectedItem: Int = -1
    private var distributedChartItems = [PNPieChartDataItem]()
    private var distributedDatas = [(color: UIColor, reside: String, resideIsNull: Bool, allCoins: Set<String>, totalPrice: Double)]()
    private var distributedChartSelectedItem: Int = -1
    private let maxChartItem = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        translateStrings()
        loadAndDisplayMoneyChart()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if UIDevice.displayNotched {
            navViewHeight.constant = 88.0
        }
        let frame = CGRect(x: 0.0, y: 0.0, width: Constant.screenWidth, height: chartViewFrame.height + 113.0)
        tableHeaderView.frame = frame
        tableView.tableHeaderView = tableHeaderView
    }
    
    deinit {
        print("deinit \(type(of: self))")
    }
}

// MARK:- Methods
extension ChartViewController {
    private func setup() {
        chartContainerView.addSubview(pieChart)
        tableView.tableHeaderView = tableHeaderView
        tableView.tableFooterView = UIView()
        tableView.registerNibCell(with: ChartStorageCell.self)
        tableView.registerNibCell(with: ChartBalancesCell.self)
        tableView.registerNibHeaderFooter(with: GroupHeaderView.self)
    }
    
    private func translateStrings() {
        setLocalizedString(with: titleLabel, key: LocalizedKey.title)
        segmentedControl.setTitle(localizedString(with: LocalizedKey.segmentedTitle1), forSegmentAt: 0)
        segmentedControl.setTitle(localizedString(with: LocalizedKey.segmentedTitle2), forSegmentAt: 1)
    }
    
    /// 统计金额分布
    private func loadAndDisplayMoneyChart() {
        if moneyChartItems.count > 0 {
            displayMoneyChart()
        } else {
            preperMoneyChartItems()
            displayMoneyChart()
        }
    }
    
    private func preperMoneyChartItems() {
        var tCoins = coins
        tCoins = tCoins.filter({ $0.num > 0.00 })
        // 根据总金额排序
        tCoins = tCoins.sorted(by: {
            let symbol0 = $0.symbol
            let symbol1 = $1.symbol
            if let price0 = coinPrice[symbol0], let price1 = coinPrice[symbol1] {
                if let p0 = price0?.price, let p1 = price1?.price {
                    return p0 * $0.num > p1 * $1.num
                }
            }
            return false
        })
        var count = tCoins.count
        if count > maxChartItem {
            count = maxChartItem
        }
        // 最多取5条数据
        for coin in tCoins[0..<count] {
            let symbol = coin.symbol
            if let price = coinPrice[symbol] {
                if let p = price?.price{
                    let totalPrice = p * coin.num
                    let index = moneyChartItems.count
                    let color = chartColors[index]
                    if let item = PNPieChartDataItem(value: CGFloat(totalPrice), color: color, description: symbol) {
                        moneyChartItems.append(item)
                        let element = (color, symbol, totalPrice)
                        moneyDatas.append(element)
                    }
                }
            }
        }
        if count >= maxChartItem {
            let theRest = tCoins[maxChartItem..<tCoins.count]
            
            var totalPrice = 0.00
            for coin in theRest {
                let s = coin.symbol
                if let price = coinPrice[s] {
                    if let p = price?.price {
                        totalPrice = totalPrice + p * coin.num
                    }
                }
            }
            
            let color = chartOtherColor
            let others = localizedString(with: LocalizedKey.others)
            if let item = PNPieChartDataItem(value: CGFloat(totalPrice), color: color, description: others) {
                moneyChartItems.append(item)
            }
            let element = (color, others, totalPrice)
            moneyDatas.append(element)
        }
    }
    
    private func displayMoneyChart() {
        pieChart.updateData(moneyChartItems as [Any])
        pieChart.stroke()
    }
    
    /// 统计分布分布
    private func loadAndDisplayDistributedChart() {
        if distributedChartItems.count > 0 {
            displayDistributedChart()
        } else {
            // 查出所有资产记录的存放地址
            let coins = MyCoin.allCoins()
            let unknowns = localizedString(with: LocalizedKey.unknowns)
            for coin in coins {
                var reside = ""
                var resideIsNull = false
                if let r = coin.reside, false == r.isEmpty {
                    reside = r
                    resideIsNull = false
                } else {
                    reside = unknowns
                    resideIsNull = true
                }
                
                var tElement = (color: UIColor(), reside: reside, resideIsNull: resideIsNull, allCoins: Set<String>(), totalPrice: 0.00)
                var tIndex = -1
                var index = 0
                for element in distributedDatas {
                    if element.reside == reside, element.resideIsNull == resideIsNull {
                        tIndex = index
                        tElement = element
                        break
                    }
                    index += 1
                }
                
                var tPrice = 0.00
                if let price = coinPrice[coin.symbol ?? ""] {
                    if let p = price?.price {
                        tPrice = p * coin.num
                    }
                }
                // 存在 追加
                if tIndex > -1 {
                    tElement.allCoins.insert((coin.symbol ?? ""))
                    tElement.totalPrice = tElement.totalPrice + tPrice
                    distributedDatas[tIndex] = tElement
                } else {
                    tElement.allCoins.insert((coin.symbol ?? ""))
                    tElement.totalPrice = tPrice
                    distributedDatas.append(tElement)
                }
            }
            
            preperDistributedChartItems()
            displayDistributedChart()
        }
    }
    
    private func preperDistributedChartItems() {
        var tDistributeds = distributedDatas
        var ttDistributeds = [(color: UIColor, reside: String, resideIsNull: Bool, allCoins: Set<String>, totalPrice: Double)]()
        // 根据总金额排序
        tDistributeds = tDistributeds.sorted(by: {
            return $0.totalPrice > $1.totalPrice
        })
        var count = tDistributeds.count
        if count > maxChartItem {
            count = maxChartItem
        }
        // 最多取5条数据
        for elment in tDistributeds[0..<count] {
            let totalPrice = elment.totalPrice
            
            var color: UIColor? = nil
            if elment.resideIsNull {
                color = chartUnknownColor
            } else {
                var index = Double(distributedChartItems.count)
                index = index.truncatingRemainder(dividingBy: Double(chartColors.count))
                color = chartColors[Int(index)]
            }
            if let c = color {
                if let item = PNPieChartDataItem(value: CGFloat(totalPrice), color: c, description: elment.reside) {
                    distributedChartItems.append(item)
                    var tElement = elment
                    tElement.color = c
                    ttDistributeds.append(tElement)
                }
            }
        }
        if count >= maxChartItem {
            let theRest = tDistributeds[maxChartItem..<tDistributeds.count]
            
            var tTotalPrice = 0.00
            var tCoins = Set<String>()
            //let count = theRest.count
            var index = 0
            var otherElement = ""
            for element in theRest {
                tTotalPrice = tTotalPrice + element.totalPrice
                
                let tItem = element.reside + ":" + allCoinsString(with: element.allCoins)
                if index == 0 {
                    otherElement = tItem
                } else {
                    otherElement = otherElement + " " + tItem
                }
                index += 1
            }
            tCoins.insert(otherElement)
            
            let color = chartOtherColor
            let others = localizedString(with: LocalizedKey.others)
            if let item = PNPieChartDataItem(value: CGFloat(tTotalPrice), color: color, description: others) {
                distributedChartItems.append(item)
                let element = (color: chartOtherColor, reside: others, resideIsNull: false, allCoins: tCoins, totalPrice: tTotalPrice)
                ttDistributeds.append(element)
            }
        }
        distributedDatas = ttDistributeds
    }
    
    private func displayDistributedChart() {
        pieChart.updateData(distributedChartItems as [Any])
        pieChart.stroke()
    }
    
    private func allCoinsString(with set: Set<String>) -> String {
        var result = ""
        var index = 0
        for item in set.sorted() {
            if index == 0 {
                result = item
            } else {
                result = result + "/" + item
            }
            index += 1
        }
        return result
    }
}

// MARK:- Events
extension ChartViewController {
    @IBAction func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func segmentedControlValueChanged() {
        moneyChartSelectedItem = -1
        distributedChartSelectedItem = -1
        if segmentedControl.selectedSegmentIndex == 0 {
            loadAndDisplayMoneyChart()
        } else {
            loadAndDisplayDistributedChart()
        }
        tableView.reloadData()
    }
}

extension ChartViewController: PNChartDelegate {
    func userClicked(onPieIndexItem pieIndex: Int) {
        if segmentedControl.selectedSegmentIndex == 0 {
            moneyChartSelectedItem = pieIndex
        } else {
            distributedChartSelectedItem = pieIndex
        }
        tableView.setContentOffset(.zero, animated: true)
        tableView.reloadData()
    }
}

extension ChartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return (moneyChartSelectedItem == -1 ? moneyDatas.count : 1)
        } else {
            return (distributedChartSelectedItem == -1 ? distributedDatas.count : 1)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        if segmentedControl.selectedSegmentIndex == 0 {
            cell = tableView.dequeueReusableNibCell(with: ChartBalancesCell.self) as! ChartBalancesCell
        } else {
            cell = tableView.dequeueReusableNibCell(with: ChartStorageCell.self) as! ChartStorageCell
        }
        
        var content = ""
        if segmentedControl.selectedSegmentIndex == 0 {
            let index = (moneyChartSelectedItem == -1 ? indexPath.row : moneyChartSelectedItem)
            let element = moneyDatas[index]
            content = element.symbol + "|\(currencySymbol)\(element.price.decimalString() ?? "0.00")"
            let aCell = (cell as! ChartBalancesCell)
            aCell.color = element.color
            aCell.content = content
        } else {
            let index = (distributedChartSelectedItem == -1 ? indexPath.row : distributedChartSelectedItem)
            let element = distributedDatas[index]
            content = element.reside + "|\(currencySymbol)\(element.totalPrice.decimalString() ?? "0.00")" + "|" + allCoinsString(with: element.allCoins)
            let aCell = (cell as! ChartStorageCell)
            aCell.color = element.color
            aCell.content = content
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

extension ChartViewController: UITableViewDelegate {
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
        if segmentedControl.selectedSegmentIndex == 0 {
            view.title = localizedString(with: LocalizedKey.segmentedTitle1)
        } else {
            view.title = localizedString(with: LocalizedKey.segmentedTitle2)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if segmentedControl.selectedSegmentIndex == 0 {
            return 45.0
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
}
