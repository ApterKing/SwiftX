//
//  HttpConfiguration.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/10.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

/// MARK: 请求配置
public extension XHttp {
    
    public struct Configuration {
        
        public var host: String?
        public var method: XHttp.Method = .GET
        public var requestSerializer: XHttp.Serializer.Request = .query
        public var responseSerializer: XHttp.Serializer.Response = .none
        
        public var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
        public var timeoutInterval: TimeInterval = 60.0
        public var allowsCellularAccess: Bool = true
        public var allHTTPHeaderFields: [String : String] = [:]
        
        public mutating func setValue(_ value: String?, forHTTPHeaderField field: String) {
            if let value = value {
                allHTTPHeaderFields[field] = value
            } else {
                allHTTPHeaderFields.removeValue(forKey: field)
            }
        }
        
        public mutating func addValue(_ value: String, forHTTPHeaderField field: String) {
            allHTTPHeaderFields[field] = value
        }
        
        fileprivate static var s_defaultConfiguration = Configuration()
        public static var defaultConfiguration: Configuration {
            get {
                return s_defaultConfiguration
            }
            set {
                URLSession.shared.getTasksWithCompletionHandler { (tasks, _, _) in
                    for task in tasks {
                        if task.state == .running || task.state == .suspended {
                            task.cancel()
                        }
                    }
                }
                s_defaultConfiguration = newValue
            }
        }
    }
    
}
