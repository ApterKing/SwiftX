//
//  CacheConfiguration.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/7.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

extension XCache {
    
    public struct Configuration {
        
        // 缓存策略，默认磁盘+内存
        public var cachePolicy: XCache.Policy.Cache = .allowed
        
        // 清空过期数据策略，默认自动
        public var expirationPolicy: XCache.Policy.Expiration = .auto
        
        // 内存缓存配置
        public var memory: Configuration.Memory = Configuration.Memory.defaultConfiguration
        
        // 磁盘缓存配置
        public var disk: Configuration.Disk = Configuration.Disk.defaultConfiguration
        
        fileprivate static var s_defaultConfiguration = Configuration()
        public static var defaultConfiguration: Configuration {
            get {
                return s_defaultConfiguration
            }
            set {
                Configuration.Memory.defaultConfiguration = newValue.memory
                Configuration.Disk.defaultConfiguration = newValue.disk
                
                XCache.default.configuration = newValue
                
                s_defaultConfiguration = newValue
            }
        }
    }
}

// MARK: 磁盘缓存配置
public extension XCache.Configuration {
    
    public struct Memory {
        
        // 非精确，0 无限制
        public var countLimit: Int = 10240
        
        // 非精确，0 无限制
        public var totalCostLimit: Int = 1024 * 1024 * 1024
        
        // 缓存数据时未设置 XCache.Expiry 的 expiry = nil时, 将会使用此值
        public var expiry: XCache.Expiry = .seconds(10 * 60)
        
        public init() {}
        
        public init(countLimit: Int, totalCostLimit: Int, expiry: XCache.Expiry) {
            self.countLimit = countLimit
            self.totalCostLimit = totalCostLimit
            self.expiry = expiry
        }
        
        fileprivate static var s_defaultConfiguration = Memory()
        public static var defaultConfiguration: Memory {
            get {
                return s_defaultConfiguration
            }
            set {
                s_defaultConfiguration = newValue
            }
        }
    }
    
}

public extension XCache.Configuration {
    
    public struct Disk {
        
        // 缓存名称，默认缓存到用户的cache目录下
        public let name: String?
        
        // 缓存路径，如果指定了缓存路径，则将使用此
        public let directoryURL: URL?
        
        // 最大缓存空间，0 无限制
        public var maxSize: UInt = 0
        
        public let fileProtection: FileProtectionType?
        
        // 缓存数据时未设置 XCacheCapsule's expiry, 将会使用此值
        public let expiry: XCache.Expiry
        
        private var _cachedURL: URL!
        public var cachedURL: URL {
            return _cachedURL
        }
        
        public init(name: String? = nil, directoryURL: URL? = nil, maxSize: UInt = 0, fileProtection: FileProtectionType? = nil, expiry: XCache.Expiry = .never) {
            self.name = name
            self.directoryURL = directoryURL
            self.maxSize = maxSize
            #if os(iOS) || os(tvOS)
            self.fileProtection = fileProtection
            #endif
            self.expiry = expiry
            
            if let url = directoryURL {
                _cachedURL = url
            } else {
                _cachedURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                _cachedURL.appendPathComponent("com.swiftx." + (name ?? "cache"), isDirectory: true)
            }
            try? FileManager.default.createDirectory(at: _cachedURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        public init(name: String) {
            self.init(name: name, directoryURL: nil, maxSize: 0, expiry: .never)
        }
        
        fileprivate static var s_defaultConfiguration = Disk()
        public static var defaultConfiguration: Disk {
            get {
                return s_defaultConfiguration
            }
            set {
                s_defaultConfiguration = newValue
            }
        }
    }
    
}
