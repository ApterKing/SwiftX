//
//  FileManager+Extension.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/27.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

public extension FileManager {
    
    public var documentDirectoryURL: URL? {
        get {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        }
    }
    
    public var libraryDirectoryURL: URL? {
        get {
            return FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
        }
    }
    
    public var cachesDirectoryURL: URL? {
        get {
            return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        }
    }
}
