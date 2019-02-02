//
//  XGlobal+Data.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/28.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

/// MARK: 将data中包含的非UTF-8字符串过滤掉
public func legalUTF8(data: Data) -> Data {
    
    //无效编码替代符号(常见 � □ ?)
    guard let replacementData = "�".data(using: .utf8) else { return data }
    var resultData = Data(capacity: data.count)
    
    var index: Int = 0
    var bytes: Array<UInt8> = [UInt8](data)
    while index < data.count {
        let header = bytes[index]
        var len = 0
        if header&0x80 == 0 {  // 单字节
            len = 1
        } else if header&0xE0 == 0xC0 {  // 2字节(非0xC0/0xC1)
            if header != 0xC0 && header != 0xC1 {
                len = 2
            }
        } else if header&0xF0 == 0xE0 {  // 3字节
            len = 3
        } else if header&0xF8 == 0xF0 {  // 4字节(非0xF5/0xF6/0xF7
            if header != 0xF5 && header != 0xF6 && header != 0xF7 {
                len = 4
            }
        }
        if len == 0 {
            resultData.append(replacementData)
            index += 1
            continue
        }
        
        var validLen: Int = 1
        while validLen < len && index + validLen < data.count {
            if bytes[index+validLen] & 0xC0 != 0x80 { break }
            validLen += 1
        }
        
        if validLen == len {
            resultData.append(&bytes[index], count: len)
        } else {
            resultData.append(replacementData)
        }
        index += validLen
    }
    return resultData
}
