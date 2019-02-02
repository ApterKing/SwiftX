//
//  Collection+Extension.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/24.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

public extension Collection {
    
    public subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
}

