//
//  XCache+Sync.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/10.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

/**
 *  MARK: 同步缓存
 *  - Usage:
 *  @see XCache.Memory
 *  @see XCache.Disk
 *  @see XCache.Hybird
 */
public extension XCache {
    
    final public class Sync: CacheAware {
        
        let innerCache: CacheAware
        let serialQueue: DispatchQueue
        
        public init(_ innerCache: CacheAware, _ serialQueue: DispatchQueue) {
            self.innerCache = innerCache
            self.serialQueue = serialQueue
        }
        
        // 存储
        public func setObject(_ object: Any, forKey key: String, expiry: XCache.Expiry?) throws {
            try serialQueue.sync {
                try innerCache.setObject(object, forKey: key, expiry: expiry)
            }
        }
        
        // 查询
        public func entry(forKey key: String) throws -> XCache.Entry {
            var entry: XCache.Entry!
            try serialQueue.sync {
                entry = try innerCache.entry(forKey: key)
            }
            return entry
        }
        
        // 移除
        public func removeObject(forKey key: String) throws {
            try serialQueue.sync {
                try innerCache.removeObject(forKey: key)
            }
        }
        
        public func removeObjectIfExpired(forKey key: String) throws {
            try serialQueue.sync {
                try innerCache.removeObjectIfExpired(forKey: key)
            }
        }
        
        public func removeAll() throws {
            try serialQueue.sync {
                try innerCache.removeAll()
            }
        }
        
        public func removeExpiredObjects() throws {
            try serialQueue.sync {
                try innerCache.removeExpiredObjects()
            }
        }
        
        // 判定数据是否存在
        public func existObject(forKey key: String) -> Bool {
            var exists = false
            serialQueue.sync {
                exists = innerCache.existObject(forKey: key)
            }
            return exists
        }
    }
}
