//
//  XCache+Async.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/10.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation


/**
 *  MARK: 异步缓存
 *  - Usage: 
 *  @see XCache.Memory
 *  @see XCache.Disk
 *  @see XCache.Hybird
 */
public extension XCache {
    
    final public class Async {
        
        let innerCache: CacheAware
        let serialQueue: DispatchQueue
        private let semaphore = DispatchSemaphore(value: 3)
        
        public init(_ innerCache: CacheAware, _ serialQueue: DispatchQueue) {
            self.innerCache = innerCache
            self.serialQueue = serialQueue
        }
        
        // 存储
        public func setObject(_ object: Any, forKey key: String, expiry: XCache.Expiry?, completion: ((Error?) -> Void)? = nil) {
            semaphore.wait()
            serialQueue.async { [weak self] in
                do {
                    try self?.innerCache.setObject(object, forKey: key, expiry: expiry)
                    completion?(nil)
                } catch let error {
                    completion?(error)
                }
                self?.semaphore.signal()
            }
        }
        
        public func setObject<T>(_ object: T, forKey key: String, from type: T.Type, expiry: XCache.Expiry?, completion: ((Error?) -> Void)? = nil) where T : Encodable {
            semaphore.wait()
            serialQueue.async { [weak self] in
                do {
                    try self?.innerCache.setObject(object, forKey: key, from: type, expiry: expiry)
                    completion?(nil)
                } catch let error {
                    completion?(error)
                }
                self?.semaphore.signal()
            }
        }
        
        // 查询
        public func entry(forKey key: String, completion: ((XCache.Entry?, Error?) -> Void)? = nil)  {
            serialQueue.async { [weak self] in
                do {
                    let entry = try self?.innerCache.entry(forKey: key)
                    completion?(entry, nil)
                } catch let error {
                    completion?(nil, error)
                }
            }
        }
        
        public func entry<T>(forKey key: String, to type: T.Type, completion: ((XCache.Entry?, Error?) -> Void)? = nil) where T : Decodable {
            serialQueue.async { [weak self] in
                do {
                    let entry = try self?.innerCache.entry(forKey: key, to: type)
                    completion?(entry, nil)
                } catch let error {
                    completion?(nil, error)
                }
            }
        }
        
        public func object(forKey key: String, completion: ((Any?, Error?) -> Void)? = nil) {
            serialQueue.async { [weak self] in
                do {
                    let object = try self?.innerCache.object(forKey: key)
                    completion?(object, nil)
                } catch let error {
                    completion?(nil, error)
                }
            }
        }
        
        public func object<T>(forKey key: String, to type: T.Type, completion: ((T?, Error?) -> Void)? = nil) where T : Decodable {
            serialQueue.async { [weak self] in
                do {
                    let object = try self?.innerCache.object(forKey: key, to: type)
                    completion?(object, nil)
                } catch let error {
                    completion?(nil, error)
                }
            }
        }
        
        // 移除
        public func removeObject(forKey key: String, completion: ((Error?) -> Void)? = nil) {
            serialQueue.async { [weak self] in
                do {
                    try self?.innerCache.removeObject(forKey: key)
                    completion?(nil)
                } catch let error {
                    completion?(error)
                }
            }
        }
        
        public func removeObjectIfExpired(forKey key: String, completion: ((Error?) -> Void)? = nil) {
            serialQueue.async { [weak self] in
                do {
                    try self?.innerCache.removeObjectIfExpired(forKey: key)
                    completion?(nil)
                } catch let error {
                    completion?(error)
                }
            }
        }
        
        public func removeAll(completion: ((Error?) -> Void)? = nil) {
            serialQueue.async { [weak self] in
                do {
                    try self?.innerCache.removeAll()
                    completion?(nil)
                } catch let error {
                    completion?(error)
                }
            }
        }
        
        public func removeExpiredObjects(completion: ((Error?) -> Void)? = nil) {
            serialQueue.async { [weak self] in
                do {
                    try self?.innerCache.removeExpiredObjects()
                    completion?(nil)
                } catch let error {
                    completion?(error)
                }
            }
        }
        
        // 判定缓存是否存在
        public func existObject(forKey key: String, completion: ((Bool) -> Void)? = nil) {
            serialQueue.async { [weak self] in
                completion?(self?.innerCache.existObject(forKey: key) ?? false)
            }
        }
        
        public func isExpiredObject(forKey key: String, completion: ((Error?) -> Void)? = nil) {
            serialQueue.async { [weak self] in
                do {
                    var expired = try self?.innerCache.isExpiredObject(forKey: key)
                    completion?(nil)
                } catch let error {
                    completion?(error)
                }
            }
        }
    }
    
}
