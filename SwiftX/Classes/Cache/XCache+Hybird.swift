//
//  XCache+Hybird.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/10.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

// MARK: 混合缓存 @see XCache.Memory, XCache.Disk
public extension XCache {
    
    final public class Hybird: CacheAware {
        
        public let memory: XCache.Memory
        public let disk: XCache.Disk
        public let configuration: XCache.Configuration
        
        public init(memory: XCache.Memory, disk: XCache.Disk, configuration: XCache.Configuration? = nil) {
            self.memory = memory
            self.disk = disk
            self.configuration = configuration ?? XCache.Configuration.defaultConfiguration
            
            // 自动移除已经过期的数据
            if self.configuration.expirationPolicy == .auto {
                DispatchQueue.global().async { [weak self] () in
                    try? self?.memory.removeExpiredObjects()
                    try? self?.disk.removeExpiredObjects()
                }
            }
        }
        
        // 存储
        public func setObject(_ object: Any, forKey key: String, expiry: XCache.Expiry?) throws {
            switch configuration.cachePolicy {
            case .allowed:
                try memory.setObject(object, forKey: key, expiry: expiry)
                try disk.setObject(object, forKey: key, expiry: expiry)
            case .allowInMemoyOnly:
                try memory.setObject(object, forKey: key, expiry: expiry)
            default:
                break
            }
        }
        
        
        // 查询
        public func entry(forKey key: String) throws -> XCache.Entry {
            guard configuration.cachePolicy != .notAllowed else {
                throw XCache.CacheError.notExists
            }
            
            do {
                return try memory.entry(forKey: key)
            } catch {
                if configuration.cachePolicy == .allowed {
                    return try disk.entry(forKey: key)
                } else {
                    throw XCache.CacheError.notExists
                }
            }
        }
        
        // 删除
        public func removeObject(forKey key: String) throws {
            try memory.removeObject(forKey: key)
            
            if configuration.cachePolicy == .allowed {
                try disk.removeObject(forKey: key)
            }
        }
        
        public func removeObjectIfExpired(forKey key: String) throws {
            try memory.removeObjectIfExpired(forKey: key)
            
            if configuration.cachePolicy == .allowed {
                try disk.removeObjectIfExpired(forKey: key)
            }
        }
        
        public func removeAll() throws {
            try memory.removeAll()
            
            if configuration.cachePolicy == .allowed {
                try disk.removeAll()
            }
        }
        
        public func removeExpiredObjects() throws {
            try memory.removeExpiredObjects()
            
            if configuration.cachePolicy == .allowed {
                try disk.removeExpiredObjects()
            }
        }
        
        // 判定数据是否存在
        public func existObject(forKey key: String) -> Bool {
            return memory.existObject(forKey: key) || disk.existObject(forKey: key)
        }
    }
    
}
