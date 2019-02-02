//
//  CachePolicy.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/7.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

extension XCache {
    
    public struct Policy {}
    
}

// MARK: 缓存策略
public extension XCache.Policy {
    
    public enum Cache {
        
        // memory & disk
        case allowed
        
        // memory
        case allowInMemoyOnly
        
        // 不缓存
        case notAllowed
    }
    
}

// MARK: 过期数据移除策略
public extension XCache.Policy {
    
    public enum Expiration {
        
        // 自动移除
        case auto
        
        // 手动移除
        case manual
        
    }
}
