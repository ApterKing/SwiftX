//
//  JSONEncoder+JSON.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/4.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

public extension JSONEncoder {
    
    static public func encode<T>(_ value: T, outputFormatting: OutputFormatting = OutputFormatting(rawValue: 0)) throws -> Data where T : Encodable {
        let encoder = JSONEncoder()
        encoder.outputFormatting = outputFormatting
        return try encoder.encode(value)
    }
    
}
