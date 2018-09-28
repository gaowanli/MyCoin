//
//  NetworkManager.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/6/7.
//  Copyright © 2017年 wl. All rights reserved.
//

import UIKit
import Alamofire

enum RequestMethod: String {
    case get    = "GET"
    case post   = "POST"
}

struct NetworkManager {
    static let share = NetworkManager()
    
    private init() {
    }
    
    func requestJSON(url: String,
                     method: RequestMethod,
                     parameters: [String: AnyObject]?,
                     completion: ((Any?, Bool, String?) -> ())? ) {
        guard let m = HTTPMethod(rawValue: method.rawValue) else {
            return
        }
        
        Alamofire.request(url,
                          method: m,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: nil).responseJSON { (response) in
                            
                            if response.result.isSuccess {
                                if let data = response.result.value {
                                    completion?(data, true, nil)
                                } else {
                                    completion?(nil, true, nil)
                                }
                            } else {
                                completion?(nil, false, response.result.error?.localizedDescription)
                            }
                            
        }
    }
}
