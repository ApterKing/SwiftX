//
//  XGlobal+Log.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/28.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

public func XLog(_ format: String, _ args: CVarArg...) {
    #if DEBUG
    NSLog("XLog -- %@", String(format: format, args))
    #endif
}
