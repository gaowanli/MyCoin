//
//  Print.swift
//  MyCoin
//
//  Created by GaoWanli on 2017/6/20.
//  Copyright © 2017年 wl. All rights reserved.
//

import Foundation

func print(_ something: @autoclosure () -> Any) {
    #if DEBUG
        Swift.print(something())
    #endif
}
