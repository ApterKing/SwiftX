//
//  HttpMethod.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/10.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

public extension XHttp {
    
    public enum Method: String {
        case GET = "GET"
        case HEAD = "HEAD"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
        case OPTIONS = "OPTIONS"
        case TRACE = "TRACE"
        case PATCH = "PATCH"
    }
    
}
