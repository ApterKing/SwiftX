//
//  XPushManager+RCT.swift
//  Swift-X
//
//  Created by wangcong on 2018/11/26.
//

import Foundation

/// MARK: 预加载
public extension XPushManager {
    
    static fileprivate var kPreloadedBridgeKey = "kPreloadedBridgeKey"
    
    class public var preloadedBridge: RCTBridge? {
        get {
            return objc_getAssociatedObject(self, &kPreloadedBridgeKey) as? RCTBridge
        }
        set {
            objc_setAssociatedObject(self, &kPreloadedBridgeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // 创建一个新的bridge
    class public func bridge(for module: String, extras: [String]? = nil) -> RCTBridge? {
        return RCTBridge(delegate: XPushRCTBridgeDelegate(module, extras), launchOptions: nil)
    }
    
    class public func preloadBridge(module: String = "Base", extras: [String]? = nil) {
        preloadedBridge?.invalidate()
        preloadedBridge = nil
        preloadedBridge = bridge(for: module, extras: extras)
    }
    
}

fileprivate class XPushRCTBridgeDelegate: NSObject, RCTBridgeDelegate {
    
    var module = ""
    var extras: [String]? = nil
    init(_ module: String, _ extras: [String]? = nil) {
        self.module = module
        self.extras = extras
    }
    
    func sourceURL(for bridge: RCTBridge!) -> URL! {
        //        #if DEBUG
        //        return  RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index", fallbackResource: nil, fallbackExtension: "js")
        //        #else
        return XPushManager.bridgeBundleURL(for: module)
        //        #endif
    }
    
    func shouldBridgeUseCxxBridge(_ bridge: RCTBridge!) -> Bool {
        return true
    }
    
    func loadSource(for bridge: RCTBridge!, with loadCallback: RCTSourceLoadBlock!) {
        var modules: [String] = []
        var bundleURLs: [URL] = []
        if extras != nil {
            for module in extras! {
                if let url = XPushManager.bridgeBundleURL(for: module) {
                    modules.append(module)
                    bundleURLs.append(url)
                }
            }
        }
        bridge.loadSource(with: modules, at: bundleURLs, onSourceLoad: loadCallback)
    }
    
}


