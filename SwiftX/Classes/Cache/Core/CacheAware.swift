//
//  CacheAware.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/6.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

public protocol CacheAware: CodableCacheAware {
    
    /**
     *  存储数据
     *  - Parameter object： 任意能够被NSKeyedArchiver存储的数据
     *  - Parameter key： 缓存中object的唯一标识
     *  - Parameter expiry:  过期时间，默认将采用Config中的值，@see XCache.Configuration
     */
    func setObject(_ object: Any, forKey key: String, expiry: XCache.Expiry?) throws
    
    
    /**
     *  获取数据
     *  - Parameter key: 指定缓存对象的唯一标识
     *  - Return XEntry: 已缓存的数据封装 for more @see XCache.Entry
     */
    func entry(forKey key: String) throws -> XCache.Entry
    
    /**
     *  获取数据
     *  - Parameter key: 指定缓存对象的唯一标识
     *  - Return Any: 已被NSKeyedArchiver缓存的数据
     */
    func object(forKey key: String) throws -> Any
    
    
    /**
     *  移除数据
     *  - Parameter key: 指定缓存对象的唯一标识
     */
    func removeObject(forKey key: String) throws
    
    /**
     *  移除数据（如果数据过期）
     *  - Parameter key: 指定缓存对象的唯一标识
     *  - Return Any: 删除的对象
     */
    func removeObjectIfExpired(forKey key: String) throws
    
    /**
     *  移除所有数据，线程阻塞，最好使用async方式 @see XCache.Async
     */
    func removeAll() throws
    
    /**
     *  移除所有过期数据，线程阻塞，最好使用async方式 @see XCache.Async
     */
    func removeExpiredObjects() throws
    
    
    /**
     *  判定数据是否存在
     *  - Parameter key: 指定缓存对象的唯一标识
     *  - Return Bool: 缓存存在则true 否则 false
     */
    func existObject(forKey key: String) -> Bool
    
    /**
     *  判定数据是否过期
     *  - Parameter key: 指定缓存对象的唯一标识
     *  - Return Bool: 如果数据不存在或者未过期则false，否则true
     */
    func isExpiredObject(forKey key: String) throws -> Bool
}

public extension CacheAware {
    
    /**
     *  获取数据
     *  - Parameter key: 指定缓存对象的唯一标识
     *  - Return Any: 已被NSKeyedArchiver缓存的数据
     */
    func object(forKey key: String) throws -> Any {
        return try entry(forKey: key).object
    }
    
    /**
     *  判定数据是否过期
     *  - Parameter key: 指定缓存对象的唯一标识
     *  - Return Bool: 如果数据不存在或者未过期则false，否则true
     */
    func isExpiredObject(forKey key: String) throws -> Bool {
        return try entry(forKey: key).expired
    }
    
}

// CodableCacheAware
public extension CacheAware {
    
    /**
     *  存储数据，如果缓存的数据不能够被JSONEncoder编码，将抛出encodingFailed @see XCache.CacheError
     *  - Parameter object： 任意能够被满足 Encodable 的数据
     *  - Parameter key： 缓存中object的唯一标识
     *  - Parameter expiry:  过期时间，默认将采用Config中的值，@see XCache.Configuration
     */
    func setObject<T>(_ object: T, forKey key: String, from type: T.Type, expiry: XCache.Expiry?) throws where T : Encodable {
        if let data = try? JSONEncoder().encode(object) {
            // 这里直接存储为Data，不使用的archiver.encodeEncodable的原因是统一解析entry
            try setObject(data, forKey: key, expiry: expiry)
        } else {
            throw XCache.CacheError.encodingFailed
        }
    }
    
    /**
     *  获取数据，如果缓存的数据不能够被JSONDecoder解析，将抛出decodingFailed @see XCache.CacheError
     *  - Parameter key: 指定缓存对象的唯一标识
     *  - Parameter type: Decodable
     *  - Return XEntry: 已缓存的数据封装 for more @see XCache.Entry
     */
    func entry<T>(forKey key: String, to type: T.Type) throws -> XCache.Entry where T : Decodable {
        let orgEntry = try entry(forKey: key)
        if let data = orgEntry.object as? Data {
            do {
                let object = try JSONDecoder().decode(type, from: data)
                let newEntry = XCache.Entry(object: object, expiry: orgEntry.expiry, fileURL: orgEntry.fileURL)
                return newEntry
            } catch {
                throw XCache.CacheError.decodingFailed
            }
        } else {
            throw XCache.CacheError.decodingFailed
        }
    }
    
    /**
     *  获取数据，如果缓存的数据不能够被JSONDecoder解析，将抛出decodingFailed @see XCache.CacheError
     *  - Parameter key: 指定缓存对象的唯一标识
     *  - Parameter type: Decodable
     *  - Return Any: 已被缓存的 Codable 数据
     */
    func object<T>(forKey key: String, to type: T.Type) throws -> T where T : Decodable {
        return try entry(forKey: key, to: type).object as! T
    }
    
}



/**
 *  Updated by wangcong on 2018/12/10.
 *  增加对@see Codable、JSONEncoder、JSONDecoder支持
 */
public protocol CodableCacheAware {
    
    /**
     *  存储数据，如果缓存的数据不能够被JSONEncoder编码，将抛出encodingFailed @see XCache.CacheError
     *  - Parameter object： 任意能够被满足 Encodable 的数据
     *  - Parameter key： 缓存中object的唯一标识
     *  - Parameter expiry:  过期时间，默认将采用Config中的值，@see XCache.Configuration
     */
    func setObject<T>(_ object: T, forKey key: String, from type: T.Type, expiry: XCache.Expiry?) throws where T : Encodable
    
    /**
     *  获取数据，如果缓存的数据不能够被JSONDecoder解析，将抛出decodingFailed @see XCache.CacheError
     *  - Parameter key: 指定缓存对象的唯一标识
     *  - Parameter type: Decodable
     *  - Return XEntry: 已缓存的数据封装 for more @see XCache.Entry
     */
    func entry<T>(forKey key: String, to type: T.Type) throws -> XCache.Entry where T : Decodable
    
    /**
     *  获取数据，如果缓存的数据不能够被JSONDecoder解析，将抛出decodingFailed @see XCache.CacheError
     *  - Parameter key: 指定缓存对象的唯一标识
     *  - Parameter type: Decodable
     *  - Return Any: 已被缓存的 Codable 数据
     */
    func object<T>(forKey key: String, to type: T.Type) throws -> T where T : Decodable
    
}

