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
     Storage Data

     - throws:
     An error of type `XCache.CacheError`.

     - parameters:
        - object: Any can be NSKeyedArchiver stored.
        - key: A unique identifier.
        - expiry: expiration time @see `XCache.Expiry`.

     */
    func setObject(_ object: Any, forKey key: String, expiry: XCache.Expiry?) throws

    /**
     Retrive Data which enclose in `XCache.Entry`

     - returns:
     `XCache.Entry`

     - throws:
     An error of type `XCache.CacheError`

     - parameters:
        - key: A unique identifier.
     */
    func entry(forKey key: String) throws -> XCache.Entry
    
    /**
     Retrive Any NSKeyedArchiver Data.

     - returns:
     `Any` which can be Archived

     - throws:
     An error of type `XCache.CacheError`

     - parameters:
        - key: A unique identifier.
     */
    func object(forKey key: String) throws -> Any
    

    /**
     Remove data from caches

     - throws:
     An error of type `XCache.CacheError`

     - parameters:
        - key: A unique identifier.
     */
    func removeObject(forKey key: String) throws
    
    /**
     Remove expired data from caches

     - throws:
     An error of type `XCache.CacheError`

     - parameters:
        - key: A unique identifier.
     */
    func removeObjectIfExpired(forKey key: String) throws

    /**
     Remove all data from caches

     - throws:
     An error of type `XCache.CacheError`
     */
    func removeAll() throws

    /**
     Remove all expired data from caches

     - throws:
     An error of type `XCache.CacheError`
     */
    func removeExpiredObjects() throws
    
    
    /**
     Judge data whether exists

     - returns:
     exists true, or false

     - parameters:
        - key: A unique identifier.
     */
    func existObject(forKey key: String) -> Bool
    
    /**
     Judge data whether expired

     - returns:
     exists true, or false

     - throws:
     if key isn't exist, throws an error of type `XCache.CacheError`

     - parameters:
        - key: A unique identifier.
     */
    func isExpiredObject(forKey key: String) throws -> Bool
}

public extension CacheAware {
    
    func object(forKey key: String) throws -> Any {
        return try entry(forKey: key).object
    }
    
    func isExpiredObject(forKey key: String) throws -> Bool {
        return try entry(forKey: key).expired
    }
    
}


/// Updated by wangcong on 2018/12/10.
/// 增加对@see Codable、JSONEncoder、JSONDecoder支持
public protocol CodableCacheAware {

    /// 存储数据，如果缓存的数据不能够被JSONEncoder编码，将抛出encodingFailed @see XCache.CacheError

    /// - Parameters:
    ///     - object: 任意能够被满足 Encodable 的数据
    ///     - key: 缓存中object的唯一标识
    ///     - type: Encodable
    ///     - expiry: 过期时间，默认将采用Config中的值，@see XCache.Configuration
    func setObject<T>(_ object: T, forKey key: String, from type: T.Type, expiry: XCache.Expiry?) throws where T : Encodable

    /// 获取数据，如果缓存的数据不能够被JSONDecoder解析，将抛出decodingFailed @see XCache.CacheError

    /// - Parameters:
    ///     - key: 指定缓存对象的唯一标识
    ///     - type: Decodable
    /// - Returns: 已缓存的数据封装 for more @see XCache.Entry
    func entry<T>(forKey key: String, to type: T.Type) throws -> XCache.Entry where T : Decodable

    /// 获取数据，如果缓存的数据不能够被JSONDecoder解析，将抛出decodingFailed @see XCache.CacheError

    /// - Parameters:
    ///     - key: 指定缓存对象的唯一标识
    ///     - type: Decodable
    /// - Returns: 已被缓存的 Codable 数据
    func object<T>(forKey key: String, to type: T.Type) throws -> T where T : Decodable

}

/// CodableCacheAware
public extension CacheAware {

    func setObject<T>(_ object: T, forKey key: String, from type: T.Type, expiry: XCache.Expiry?) throws where T : Encodable {
        if let data = try? JSONEncoder().encode(object) {
            try setObject(data, forKey: key, expiry: expiry)
        } else {
            throw XCache.CacheError.encodingFailed
        }
    }
    
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
    
    func object<T>(forKey key: String, to type: T.Type) throws -> T where T : Decodable {
        return try entry(forKey: key, to: type).object as! T
    }
    
}
