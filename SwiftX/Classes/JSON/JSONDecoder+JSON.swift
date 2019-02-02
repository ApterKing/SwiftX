//
//  JSONDecoder+JSON.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/4.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

/**
 *  MARK: JSONDecoder提供类方法解析 Array、Dictionary、String、Data能力
 *  - Usage:
 *    let _ = try? JSONDecoder.decode(XX.self, from: object)
 *
 *  MARK: JSONDecoder提供 keyPath解析能力，注意：这里的KeyPath以"."连接
 *  - Usage:
 *    let object = ["name": "测试", "person": ["name": "测试人姓名", "child": ["cry": true]]]
 *    if let person = try? JSONDecoder.decode(Person.self, from: object, forKey: "person") {
 *          print(person.name) // 测试人姓名
 *    }
 *
 *    if let child = JSONDecoder.decode(Child.self, from: object, forKeyPath: "person.child") {
 *          print(child.cry) // true
 *    }
 *
 */
public extension JSONDecoder {
    
    // MARK: 非key/keyPath
    static public func decode<T>(_ type: T.Type, from object: Any) throws -> T where T : Decodable {
        return try decode(type, from: object, forKeyPath: nil)
    }
    
    // MARK: key
    static public func decode<T>(_ type: T.Type, from object: Any, forKey key: String? = nil) throws -> T where T : Decodable {
        return try decode(type, from: object, forKeyPath: key)
    }
    
    // MARK: keyPath
    static public func decode<T>(_ type: T.Type, from object: Any, forKeyPath keyPath: String? = nil) throws -> T where T : Decodable {
        if let string = object as? String {
            guard let data = string.data(using: .utf8) else {
                throw NSError(domain: kJSONDecoderDomain, code: JSONError.illegalUTF8Data.rawValue, userInfo: [NSLocalizedDescriptionKey: JSONError.illegalUTF8Data.description])
            }
            return try decode(T.self, from: data, forKeyPath: keyPath)
        } else if let data = object as? Data {
            return try decode(T.self, from: data, forKeyPath: keyPath)
        } else if JSONSerialization.isValidJSONObject(object) {
            do {
                let data = try JSONSerialization.data(with: object, options: [])
                return try decode(T.self, from: data, forKeyPath: keyPath)
            } catch let error {
                throw error
            }
        } else {
            throw NSError(domain: kJSONDecoderDomain, code: JSONError.illegalConvert.rawValue, userInfo: [NSLocalizedDescriptionKey: JSONError.illegalConvert.description + " to \(T.self)"])
        }
    }

}

/// MARK: keyPath 解析
extension JSONDecoder {
    
    static private let keyPathCodingUserInfoKey = CodingUserInfoKey(rawValue: "keyPathCodingUserInfoKey")!
    static private func decode<T>(_ type: T.Type, from data: Data, forKeyPath keyPath: String? = nil) throws -> T where T : Decodable {
        let decoder = JSONDecoder()
        
        guard let keyPath = keyPath else {
            return try decoder.decode(T.self, from: data)
        }
        
        decoder.userInfo[keyPathCodingUserInfoKey] = keyPath.components(separatedBy: ".")
        return try decoder.decode(KeyPathWrapper<T>.self, from: data).object
    }
    
    // 自定义CodingKey
    private struct KeyPathCodingKey: CodingKey {
        public var stringValue: String

        public init(stringValue: String) {
            self.stringValue = stringValue
        }
        
        public var intValue: Int?
        
        public init(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
    }
    
    // KeyPath封装
    private final class KeyPathWrapper<T>: Decodable where T: Decodable {
        private typealias KeyedContainer = KeyedDecodingContainer<KeyPathCodingKey>
        
        var object: T
        
        init(from decoder: Decoder) throws {
            guard let keyPath = decoder.userInfo[keyPathCodingUserInfoKey] as? [String], !keyPath.isEmpty else {
                throw NSError(domain: kJSONDecoderDomain, code: JSONError.illegalKeyPath.rawValue, userInfo: [NSLocalizedDescriptionKey: JSONError.illegalKeyPath.description])
            }
            
            func keyPathCodingKey(from keyPath: [String]) -> KeyPathCodingKey {
                return KeyPathCodingKey(stringValue: (keyPath.first)!)
            }
            
            func objectContainer(for keyPath: [String],
                                 container: KeyedContainer,
                                 codingKey: KeyPathCodingKey) throws -> (KeyedContainer, KeyPathCodingKey) {
                guard !keyPath.isEmpty else { return (container, codingKey) }
                let nestedContainer = try container.nestedContainer(keyedBy: KeyPathCodingKey.self, forKey: codingKey)
                let nestedCodingKey = try keyPathCodingKey(from: keyPath)
                return try objectContainer(for: Array(keyPath.dropFirst()), container: nestedContainer, codingKey: nestedCodingKey)
            }
            
            let codingKey = try keyPathCodingKey(from: keyPath)
            let container = try decoder.container(keyedBy: KeyPathCodingKey.self)
            let (keyedContainer, key) = try objectContainer(for: Array(keyPath.dropFirst()), container: container, codingKey: codingKey)
            object = try keyedContainer.decode(T.self, forKey: key)
        }
    }
}

/// MARK: 解析错误代码
public extension JSONDecoder {
    static public let kJSONDecoderDomain = "com.swiftx.JSONDecoderDomain"
    public enum JSONError: Int {
        case noError = 0
        
        case illegalUTF8Data = -1
        case illegalConvert = -2
        case illegalKeyPath = -3
        
        var description: String {
            get {
                switch self {
                case .illegalUTF8Data:
                    return "illegal utf8 string"
                case .illegalConvert:
                    return "object can not be converted"
                case .illegalKeyPath:
                    return "keyPath not be nil or empty"
                default:
                    return "no error"
                }
            }
        }
    }
}
