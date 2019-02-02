//
//  XCache+Memory.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/10.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

/**
 *  内存缓存
 *  - Usage:
 *
 *      - Initial:
 *
 *      let configuration = XCache.Configuration.Memory(countLimit: 1024, totalCostLimit: 1024 * 1024 * 1024, expiry: .never)
 *      XCache.Configuration.Memory.defaultConfiguration = configuration  // 将会更改全局Memory的默认配置
 *      let memory = XCache.Memory(XCache.Configuration.Memory.defaultConfiguration)
 *      // or
 *      let memory = XCache.Memory(configuration)
 *
 *      - Fetch:
 *
 *      if let entry = try? memory.entry(forKey: "person", to: Person.self) {
 *          print((entry.object as! Person).age)
 *          print(entry.expiry)
 *          print(entry.fileURL) // always nil
 *      }
 *
 *      ... for more @see CacheAware
 */
public extension XCache {
    
    final public class Memory: CacheAware {
        
        fileprivate var keys: Set<String> = Set()
        fileprivate let cache: NSCache<NSString, XCache.Entry>
        
        fileprivate let config: XCache.Configuration.Memory
        public init(_ config: XCache.Configuration.Memory) {
            self.config = config
            
            self.cache = NSCache()
            self.cache.totalCostLimit = config.totalCostLimit
            self.cache.countLimit = config.countLimit
            
            NotificationCenter.default.addObserver(self, selector: #selector(tryRemoveAll), name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(tryRemoveAll), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        }
        
        @objc func tryRemoveAll() {
            try? removeAll()
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        // 存储
        public func setObject(_ object: Any, forKey key: String, expiry: XCache.Expiry?) throws {
            let entry = XCache.Entry(object: object, expiry: expiry ?? config.expiry)
            cache.setObject(entry, forKey: NSString(string: key))
            keys.insert(key)
        }
        
        // 查询
        public func entry(forKey key: String) throws -> XCache.Entry {
            guard let entry = cache.object(forKey: NSString(string: key)) else {
                throw XCache.CacheError.notExists
            }
            return entry
        }
        
        // 删除
        public func removeObject(forKey key: String) throws {
            let entry = try self.entry(forKey: key)
            
            if existObject(forKey: key) {
                cache.removeObject(forKey: NSString(string: key))
                keys.remove(key)
            } else {
                throw XCache.CacheError.notExists
            }
        }
        
        public func removeObjectIfExpired(forKey key: String) throws {
            let entry = try self.entry(forKey: key)
            
            if entry.expired {
                cache.removeObject(forKey: NSString(string: key))
                keys.remove(key)
            }
        }
        
        public func removeAll() throws {
            cache.removeAllObjects()
            keys.removeAll()
        }
        
        public func removeExpiredObjects() throws {
            for key in keys {
                try removeObjectIfExpired(forKey: key)
            }
        }
        
        // 判定是否存在数据
        public func existObject(forKey key: String) -> Bool {
            return keys.contains(key)
        }
        
    }
    
}
