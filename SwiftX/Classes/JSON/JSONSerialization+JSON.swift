//
//  JSONSerialization+JSON.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/4.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

public extension JSONSerialization {
    
    public typealias JSONString = String
    public typealias JSONObject = Any
    public typealias JSONData = Data
    
    /// MARK: Any -> Data
    class public func data(with jsonObject: JSONObject, options: WritingOptions = []) -> JSONData? {
        return try? JSONSerialization.data(withJSONObject: jsonObject, options: options)
    }
    
    /// MARK: Any -> JSONString
    class public func string(with jsonObject: JSONObject, options: WritingOptions = []) -> JSONString? {
        guard JSONSerialization.isValidJSONObject(jsonObject), let data = data(with: jsonObject, options: options) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// MARK: Data -> JSONObject
    class public func object(with jsonData: JSONData, options: ReadingOptions = .allowFragments) -> JSONObject? {
        return try? JSONSerialization.jsonObject(with: jsonData, options: options)
    }
    
    /// MARK: JSONString -> Any
    class public func object(with jsonString: JSONString, options: ReadingOptions = .allowFragments) -> JSONObject? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: options)
    }

    
}
