//
//  UserDefaults+Extension.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/07.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

// MARK: - Subscript
public extension UserDefaults {
    
    public subscript(key: String) -> Any? {
        get {
            return object(forKey: key)
        }
        set {
            set(newValue, forKey: key)
        }
    }
}

// MARK: -
public extension UserDefaults {
    
    public static func contains(key: String) -> Bool {
        return self.standard.contains(key: key)
    }
    
    public func contains(key: String) -> Bool {
        return self.dictionaryRepresentation().keys.contains(key)
    }
    
    public func reset() {
        for key in Array(UserDefaults.standard.dictionaryRepresentation().keys) {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
}
