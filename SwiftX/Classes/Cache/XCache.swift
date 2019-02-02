//
//  XCache.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/5.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

/**
 *  XCache缓存，支持能够被NSKeyedArchiver编码存储的数据：
 *      NSNumber/Dictionary/NSDictionary/Array/Data/NSData/UIImage/Int/UInt... 以及 T: Encodable
 *
 *  - Functions
 *      - 缓存配置:              @see XCache.Configuration
 *      - 内存缓存: 可单独使用     @see XCache.Memory
 *      - 磁盘缓存: 可单独使用     @see XCache.Disk
 *      - 混合缓存: 可单独使用     @see XCache.Hybird，
 *      - 混合同步缓存: 可单独使用  @see XCache.Sync，
 *      - 混合异步缓存: 可单独使用  @see XCache.Async，
 *
 *  - Usage
 *
 *      - Example:
 *      class Person: NSObject, Codable {
 *          var age: Int
 *          var firstName: String
 *          var address: Address
 *      }
 *
 *      - Initial:
 *
 *      // 默认的初始方法
 *      try? XCache.default.setObject(leon, forKey: "person", from: Person.self, expiry: .never)
 *      // 还可以全局默认配置
 *      let configuration = XCache.Configuration.defaultConfiguration
 *      let diskConfiguration = XCache.Configuration.Disk(name: "test")
 *      let memoryConfiguration = XCache.Configuration.Memory(countLimit: 10240, totalCostLimit: 1024 * 1024 * 1024, expiry: .never)
 *      configuration.cachePolicy = .allowed
 *      configuration.expirationPolicy = .auto
 *      configuration.disk = diskConfiguration
 *      configuration.memory = memoryConfiguration
 *      XCache.Configuration.defaultConfiguration = configuration
 *
 *      - Async:
 *      // XCache 默认采用Hybird存储，并且是同步存储，如果需要使用异步：
 *      XCache.default.async.setObject(leon, forKey: "person", from: Person.self, expiry: .never) { (_) in
 *          // save success
 *      }
 *      XCache.default.async.object(forKey: "person", to: Person.self) { (result) in
 *          switch result {
 *          case .success(let person):
 *              print(person.age)
 *          case .failure(let error):
 *              print(String(describing: error))
 *          }
 *      }
 *
 *      for more async @see XCache.Async
 */
final public class XCache: CacheAware {
    
    static public let `default` = XCache()
    public lazy var async = self.asyncCache

    internal var configuration: Configuration
    private let hybirdCache: XCache.Hybird
    private let syncCache: XCache.Sync
    private let asyncCache: XCache.Async

    public init(_ configuration: Configuration? = nil) {
        self.configuration = configuration ?? Configuration.defaultConfiguration

        let diskCache = XCache.Disk(self.configuration.disk)
        let memoryCache = XCache.Memory(self.configuration.memory)
        hybirdCache = XCache.Hybird(memory: memoryCache, disk: diskCache)

        syncCache = XCache.Sync(hybirdCache, DispatchQueue(label: "com.swiftx.cache.sync"))
        asyncCache = XCache.Async(hybirdCache, DispatchQueue(label: "com.swiftx.cache.async"))
    }

    // 同步存储
    public func setObject(_ object: Any, forKey key: String, expiry: XCache.Expiry?) throws {
        try syncCache.setObject(object, forKey: key, expiry: expiry)
    }
    
    // 同步查询
    public func entry(forKey key: String) throws -> XCache.Entry {
        return try syncCache.entry(forKey: key)
    }
    
    // 同步删除
    public func removeObject(forKey key: String) throws {
        try syncCache.removeObject(forKey: key)
    }
    
    public func removeObjectIfExpired(forKey key: String) throws {
        try syncCache.removeObjectIfExpired(forKey: key)
    }
    
    public func removeAll() throws {
        try syncCache.removeAll()
    }
    
    public func removeExpiredObjects() throws {
        try syncCache.removeExpiredObjects()
    }
    
    // 判定数据是否存在
    public func existObject(forKey key: String) -> Bool {
        return syncCache.existObject(forKey: key)
    }
}
