//
//  HttpSerializer.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/10.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

// 数据序列化
public extension XHttp {
    
    public struct Serializer {}
    
}

// 请求参数编码
public extension XHttp.Serializer {
    
    public enum Request: Int {
        case none = 0  // 无需编码数据
        case json = 1  // 将数据编码为json格式
        case query = 2   // 将数据编码为key=value
    }
    
}

// 响应参数解析
public extension XHttp.Serializer {
    
    public enum Response: Int {
        case none = 0     // 无需解析数据
        case json = 1     // 解析为JSONObject
        case xml = 2      // 暂不支持
    }
    
}
