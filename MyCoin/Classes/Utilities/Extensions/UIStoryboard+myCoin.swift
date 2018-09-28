//
//  UIStoryboard+myCoin.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/10/30.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation

enum Storyboard: String {
    case main = "Main"
}

enum Identifier: String {
    case tabBar         = "TabBarController"
    case collection     = "CollectionViewController"
    case editAsset      = "EditAssetViewController"
    case viewAsset      = "ViewAssetViewController"
    case editProject    = "EditProjectViewController"
    case currency       = "CurrencyViewController"
    case search         = "SearchViewController"
    case percent        = "PercentChangeViewController"
    case wallet         = "WalletViewController"
    case exchange       = "ExchangeController"
    case editWallet     = "EditWalletViewController"
    case editExchange   = "EditExchangeViewController"
    case signIn         = "UserSignInViewController"
    case signUp         = "UserSignUpViewController"
    case auth           = "AuthViewController"
    case chart          = "ChartViewController"
    case feedback       = "FeedbackViewController"
    case message        = "MessageViewController"
    case messageDetail  = "MessageDetailViewController"
    case pushMessage    = "PushMessageViewController"
}
