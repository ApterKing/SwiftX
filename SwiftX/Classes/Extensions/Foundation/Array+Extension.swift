//
//  Array+Extension.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/12.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

// MARK: delete
public extension Array where Element: Equatable {

    public mutating func remove(element: Iterator.Element) -> Bool {
        if let index = self.index(of: element) {
            self.remove(at: index)
            return true
        }
        return false
    }
    
}


