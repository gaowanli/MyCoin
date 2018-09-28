//
//  LeanCloudManager.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/11/17.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation

struct LeanCloudClass {
    static let coin         = "Coin"
    static let wallet       = "Wallet"
    static let exchange     = "Exchange"
    static let collection   = "Collection"
    static let configure    = "Configure"
    static let appleAuth    = "AppleInReview"
    static let feedback     = "Feedback"
    static let message      = "Message"
}

enum CoinClass: String {
    case id
    case userObjectId
    case name
    case symbol 
    case num
    case reside
    case exchangeOrWallet
    case buyPrice
    case unitOrTotal
    case currency
    case buyDate
    case remarks 
    
    var column: String {
        return self.rawValue
    }
}

enum WalletClass: String {
    case id
    case userObjectId
    case name
    case remarks
    
    var column: String {
        return self.rawValue
    }
}

enum ExchangeClass: String {
    case id
    case userObjectId
    case name
    case remarks
    
    var column: String {
        return self.rawValue
    }
}

enum CollectionClass: String {
    case id
    case userObjectId
    case name
    case symbol
    case sort
    case visible
    
    var column: String {
        return self.rawValue
    }
}

enum ConfigureClass: String {
    case userObjectId
    case configure
    
    var column: String {
        return self.rawValue
    }
}

enum AppleAuthClass: String {
    case version
    case build
    case ing
    case url
    case timestamp
    case updateTips
    case updateTipsEN
    
    var column: String {
        return self.rawValue
    }
}

enum FeedbackClass: String {
    case userObjectId
    case content
    case version
    
    var column: String {
        return self.rawValue
    }
}

enum MessageClass: String {
    case userObjectId
    case title
    case titleEN
    case content
    case contentEN
    case timestamp
    case toAll          // 0:指定用户 1:全部用户
    case type           // 0:系统消息 1:反馈回复
    case createdAt
    
    var column: String {
        return self.rawValue
    }
}
