//
//  CacheEntry.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/7.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

extension XCache {
    
    // MARK: 缓存数据封装，用于memory缓存及查询数据封装
    final public class Entry: NSObject {
        
        // 数据
        public let object: Any
        
        // 过期时间
        public let expiry: XCache.Expiry
        
        // 磁盘路径，如果未存储磁盘，此值为nil
        public let fileURL: URL?
        
        // 是否过期
        public var expired: Bool {
            return expiry.date.timeIntervalSince(Date()) < 0
        }
        
        init(object: Any, expiry: XCache.Expiry, fileURL: URL? = nil) {
            self.object = object
            self.expiry = expiry
            self.fileURL = fileURL
        }
        
    }
    
}
