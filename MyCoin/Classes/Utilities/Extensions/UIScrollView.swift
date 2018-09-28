//
//  UIScrollView.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/7/20.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit

extension UIScrollView {
    func registerNibCell(with cellClass: AnyClass) {
        if let id = idStr(with: cellClass) {
            let nib = UINib(nibName: id, bundle: nil)
            
            if let t = self as? UITableView {
                t.register(nib, forCellReuseIdentifier: id)
            } else if let c = self as? UICollectionView {
                c.register(nib, forCellWithReuseIdentifier: id)
            }
        }
    }
    
    func dequeueReusableNibCell(with cellClass: AnyClass, indexPath: IndexPath? = nil) -> Any? {
        if let id = idStr(with: cellClass) {
            if let t = self as? UITableView {
                if let `indexPath` = indexPath {
                    return t.dequeueReusableCell(withIdentifier: id, for: `indexPath`)
                } else {
                    return t.dequeueReusableCell(withIdentifier: id)
                }
            } else if let c = self as? UICollectionView {
                if let `indexPath` = indexPath {
                    return c.dequeueReusableCell(withReuseIdentifier: id, for: `indexPath`)
                } else {
                    return UICollectionViewCell()
                }
            }
        }
        return nil
    }
    
    func registerNibHeaderFooter(with viewClass: AnyClass) {
        if let id = idStr(with: viewClass) {
            let nib = UINib(nibName: id, bundle: nil)
            
            if let t = self as? UITableView {
                t.register(nib, forHeaderFooterViewReuseIdentifier: id)
            }
        }
    }
    
    func dequeueReusableHeaderFooter(with viewClass: AnyClass) -> Any? {
        if let id = idStr(with: viewClass) {
            if let t = self as? UITableView {
                return t.dequeueReusableHeaderFooterView(withIdentifier: id)
            }
        }
        return nil
    }
    
    private func idStr(with viewClass: AnyClass) -> String? {
        let desc = viewClass.description()
        guard desc.contains(".") else {
            return nil
        }
        return desc.components(separatedBy: ".").last
    }
}
