//
//  Bundle+Extension.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/26.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

public extension Bundle {
    
    static var bundleShortVersion: String? {
        get {
           return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        }
    }
    
    static var bundleName: String? {
        get {
            return Bundle.main.infoDictionary?["CFBundleName"] as? String
        }
    }
    
    static var bundleVersion: String? {
        get {
            return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        }
    }
    
    static var bundleIdentifier: String? {
        get {
            return Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
        }
    }
}

