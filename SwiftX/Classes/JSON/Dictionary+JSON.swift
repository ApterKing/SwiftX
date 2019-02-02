//
//  Dictionary+JSON.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/4.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

/// MARK: JSONSerialization
public extension Dictionary {
    
    func toJSONData(_ options: JSONSerialization.WritingOptions = []) -> Data? {
        return JSONSerialization.data(with: self, options: options)
    }
    
    func toJSONString(_ options: JSONSerialization.WritingOptions = []) -> String? {
        return JSONSerialization.string(with: self, options: options)
    }
    
}

/// MARK: JSONEncoder
public extension Dictionary where Key == String, Value: Encodable {
    
    func toJSONData(_ outputFormatting: JSONEncoder.OutputFormatting = JSONEncoder.OutputFormatting(rawValue: 0)) -> Data? {
        return try? JSONEncoder.encode(self, outputFormatting: outputFormatting)
    }
    
    func toJSONString(_ outputFormatting: JSONEncoder.OutputFormatting = JSONEncoder.OutputFormatting(rawValue: 0)) -> String? {
        guard let data = try? JSONEncoder.encode(self, outputFormatting: outputFormatting) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
}

/// MARK: JSONDecoder
public extension Dictionary where Key == String, Value: Decodable {
    
    func toJSONObject<T>() -> T? where T : Decodable {
        return try? JSONDecoder.decode(T.self, from: self)
    }
    
}
