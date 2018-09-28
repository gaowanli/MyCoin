//
//  Constant.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/6/7.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct Constant {
    static let navBarHeight: CGFloat = UIDevice.displayNotched ? 88.0 : 64.0
    static let tabBarHeight: CGFloat = UIDevice.displayNotched ? 83.0 : 49.0
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    static let dateFormatter = DateFormatter()
    static let numberFormater = NumberFormatter()
    static let minNumber: Double = 0.000001
    
    // MARK: - Core Data stack
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Entities")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
            }
        })
        return container
    }()
    
    static var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
}
