//
//  HttpError.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/10.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

public extension XHttp {
    
    public enum HttpError: Error {
        
        case noError
        
        // "请求参数序列化错误"
        case requestSerializerError
        
        // "响应参数序列化错误"
        case responseSerializerError
        
        // "请求服务器，参数错误"
        case serverSystemError
        
        // "写入文件失败，请检查需要写入的地址是否正确"
        case fileWriteError
        
    }
    
}
