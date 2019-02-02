//
//  CacheExpiry.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/7.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

extension XCache {
    
    // MARK: 缓存时间
    public enum Expiry {
        
        case never
        
        case seconds(TimeInterval)
        
        case date(Date)
        
        public var date: Date {
            switch self {
            case .never:
                return Date(timeIntervalSince1970: 100 * 365 * 24 * 3600)
            case .seconds(let seconds):
                return Date(timeInterval: seconds, since: Date())
            case .date(let date):
                return date
            }
        }
        
    }
    
}
