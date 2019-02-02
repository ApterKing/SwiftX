//
//  CacheError.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/7.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

extension XCache {
    
    // MARK: 错误信息
    public enum CacheError: Error {
        
        // 未查找到数据
        case notExists
        
        // JSONDecoder fail
        case decodingFailed
        
        // NSKeyedArchiver JSONEncoder  fail
        case encodingFailed
        
        // 读取数据失败(仅存在于磁盘存储）
        case dataReadFailed
        
        // 数据写入失败(仅存在于磁盘存储）
        case dataWriteFailed
    }
    
}
