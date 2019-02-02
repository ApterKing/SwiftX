//
//  XPushManager.swift
//  Swift-X
//
//  Created by wangcong on 2018/11/26.
//

import UIKit
import SSZipArchive

/// MARK: global
let kSuitNameKey = "RNPush"
func XPushLog(_ format: String, _ args: CVarArg...) {
    #if DEBUG
    NSLog(format, args)
    #endif
}


/**
 *
 * 应用包模块结构
 * [main.jsbundle] -- 可配置
 * --- assets
 * --- [moduleA].js,[moduleB].js,...
 * --- [moduleA].js.meta,[moduleB].js.meta,...
 * --- [moduleA].manifest.json,[moduleB].manifest.json,...
 *
 * 升级单个模块适用目录结构为：
 * [module]
 * --- assets
 * --- [module].js
 * --- [module].js.meta
 * --- [module].manifest.json
 *
 * Updated by wangcong on 2018/10/31，修改为单Bridge
 *
 */
public class XPushManager: NSObject {
    
    static let kBundleResourceKey = "com.RNPush.kBundleResourceKey"
    static let kRollbackKey = "com.RNPush.kRollbackKey"
    static let kRollbackBugBuildhashKey = "com.RNPush.kRollbackBugBuildhashKey"
    static let kModuleUpdatedBuildhashKey = "com.RNPuhs.kUpdatedBuildhashKey"
    static let kModuleStatusKey = "com.RNPush.kModuleStatusKey"
    static let kPatchSuffixKey = ".patch"
    static let kRollBackPrefixKey = "rollback_"
    
    static let bundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "RNPush"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    static let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    struct XPushManagerStatus {
        static let pending: Int64 = 0
        static let success: Int64 = 1
        static let fail: Int64 = 2
    }
    
}

public extension XPushManager {
    
    /// 注册相关配置，此方法在willFinishLaunchingWithOptions/didFinishLaunchingWithOptions中需要调用
    class public func register(serverUrl: String, deploymentKey: String, bundleResource: String = "main.jsbundle") {
        RNPushConfig.register(serverUrl: serverUrl, deploymentKey: deploymentKey)
        let userDefaults = UserDefaults(suiteName: kSuitNameKey) ?? UserDefaults.standard
        userDefaults.set(bundleResource, forKey: kBundleResourceKey)
        
        XPushManagerMonitor.default.registerNotification()
        rollbackIfNeeded { (_) in
            preloadBridge(module: "Base", extras: ["TimeSpace", "AngelQA"])
        }
    }
    
    class public func bundleURL() -> URL? {
        var url: URL? = sanboxBundleURL()
        if url == nil {
            url = binaryBundleURL()
        }
        
        XPushLog("XPushManager  bundlePath:   \(String(describing: url?.absoluteString))")
        return url
    }
    
    class public func bridgeBundleURL(for module: String) -> URL? {
        return bundleURL()?.appendingPathComponent("\(module).js")
    }
    
    // 沙盒
    class func sanboxBundleURL() -> URL? {
        let bundlePath = sanboxBundlePath()
        if FileManager.default.fileExists(atPath: bundlePath) {
            return URL(fileURLWithPath: bundlePath)
        }
        return nil
    }
    
    // 应用包
    class func binaryBundleURL() -> URL? {
        let userDefaults = UserDefaults(suiteName: kSuitNameKey) ?? UserDefaults.standard
        let bundleResource = userDefaults.string(forKey: kBundleResourceKey) ?? "main.jsbundle"
        return Bundle.main.url(forResource: bundleResource, withExtension: nil)
    }
    
    // 更改本地存储的当前模块状态
    class func markStatus(for module: String, buildHash: String, status: Int64, shouldPostNotification: Bool = true) {
        let userDefaults = UserDefaults(suiteName: kSuitNameKey) ?? UserDefaults.standard
        var statusDic = userDefaults.dictionary(forKey: kModuleStatusKey) as? [String: [String : Any]] ?? [:]
        
        let condition0 = (status == XPushManagerStatus.pending)
        var condition1 = false
        if status != XPushManagerStatus.pending, let savedStatus = statusDic[buildHash]?["status"] as? Int64, let savedModule = statusDic[buildHash]?["module"] as? String, savedStatus == XPushManagerStatus.pending, savedModule == module {
            condition1 = true
        }
        if condition0 || condition1 {
            if shouldPostNotification {
                let userInfo: [String: Any] = [
                    "module": module,
                    "status": status,
                    "buildHash": buildHash
                ]
                NotificationCenter.default.post(name: Notification.Name(kModuleStatusKey), object: nil, userInfo: userInfo)
            } else {
                statusDic[buildHash] = ["status": status, "module": module]
                userDefaults.set(statusDic, forKey: kModuleStatusKey)
            }
        }
    }
}

/// MARK: 回滚
extension XPushManager {
    
    // 添加某个模块到待回滚队列
    class public func addRollbackIfNeeded(for module: String) {
        let userDefaults = UserDefaults(suiteName: kSuitNameKey) ?? UserDefaults.standard
        var rollbackModules = userDefaults.array(forKey: kRollbackKey) as? [String] ?? []
        if !rollbackModules.contains(module) {
            rollbackModules.append(module)
        }
        userDefaults.set(rollbackModules, forKey: kRollbackKey)
    }
    
    // 将某个模块移除待回滚队列，并且是否标定为热更成功模块
    class public func removeRollbackIfNeeded(for module: String, shouldMarked success: Bool = true) {
        let userDefaults = UserDefaults(suiteName: kSuitNameKey) ?? UserDefaults.standard
        var rollbackModules = userDefaults.array(forKey: kRollbackKey) as? [String] ?? []
        if let index = rollbackModules.index(of: module) {
            rollbackModules.remove(at: index)
            
            // 移除则意味着此次获取的热更版本成功
            if success {
                markStatus(for: module, buildHash: XPushManager.buildHash(for: module), status: XPushManagerStatus.success)
            }
        }
        userDefaults.set(rollbackModules, forKey: kRollbackKey)
    }
    
    // 检测某个构建版本是否存在bug
    class func isBugBuildHash(for buildHash: String) -> Bool {
        let userDefaults = UserDefaults(suiteName: kSuitNameKey) ?? UserDefaults.standard
        let rollbackBugBuildhashs = userDefaults.array(forKey: kRollbackBugBuildhashKey) as? [String] ?? []
        return rollbackBugBuildhashs.contains(buildHash)
    }
    
    // 回滚更新出错的所有模块
    class func rollbackIfNeeded(_ completion: ((_ error: Error?) -> Void)? = nil) {
        DispatchQueue(label: "com.RNPush.rollback").async {
            do {
                let userDefaults = UserDefaults(suiteName: kSuitNameKey) ?? UserDefaults.standard
                let rollbackModules = userDefaults.array(forKey: kRollbackKey) as? [String] ?? []
                var rollbackBugBuildhashs = userDefaults.array(forKey: kRollbackBugBuildhashKey) as? [String] ?? []
                
                for module in rollbackModules {
                    let buildHash = XPushManager.buildHash(for: module)
                    // 标定位bug
                    if !rollbackBugBuildhashs.contains(buildHash) {
                        rollbackBugBuildhashs.append(buildHash)
                    }
                    removeRollbackIfNeeded(for: module, shouldMarked: false)
                    
                    markStatus(for: module, buildHash: XPushManager.buildHash(for: module), status: XPushManagerStatus.fail)
                }
                userDefaults.set(rollbackBugBuildhashs, forKey: kRollbackBugBuildhashKey)
                
                // 存在需要回滚的模块则回滚
                if rollbackModules.count != 0 {
                    try XPushManager.rollback()
                }
                DispatchQueue.main.async {
                    completion?(nil)
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion?(error)
                }
            }
        }
    }
    
    class func rollback() throws {
        let bundlePath = XPushManager.sanboxBundlePath()
        let rollbackPath = XPushManager.sanboxRollbackPath()
        
        try FileManager.default.removeItem(atPath: bundlePath)
        if FileManager.default.fileExists(atPath: rollbackPath) {
            try FileManager.default.moveItem(atPath: rollbackPath, toPath: bundlePath)
        }
    }
    
}

/// MARK: 本地文件处理
extension XPushManager {
    
    // 热更文件存储所在的文件夹
    class func sanboxPath(_ pathComponent: String = "", isDirectory: Bool = true) -> String {
        let supportPath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first ?? ""
        var sanboxPath = "\(supportPath)/\(XPushManager.bundleName)_\(XPushManager.appVersion)_\(XPushManager.buildVersion)"
        if !FileManager.default.fileExists(atPath: sanboxPath, isDirectory: nil) {
            try? FileManager.default.createDirectory(atPath: sanboxPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        if pathComponent != "" {
            sanboxPath = sanboxPath.appendingFormat("/%@", pathComponent)
            if isDirectory && !FileManager.default.fileExists(atPath: sanboxPath, isDirectory: nil) {
                try? FileManager.default.createDirectory(atPath: sanboxPath, withIntermediateDirectories: true, attributes: nil)
            }
        }
        return sanboxPath
    }
    
    // 更新压缩文件存储地址
    class func sanboxPatchPath(for module: String) -> String {
        return sanboxPath() + "/" + module + kPatchSuffixKey
    }
    
    // 更新文件解压地址
    class func sanboxUnpatchedPath(for module: String) -> String {
        return sanboxPath() + "/" + module
    }
    
    class func sanboxBundlePath() -> String {
        let userDefaults = UserDefaults(suiteName: kSuitNameKey) ?? UserDefaults.standard
        let bundleResource = userDefaults.string(forKey: kBundleResourceKey) ?? "main"
        return sanboxPath() + "/" + bundleResource
    }
    
    class func sanboxRollbackPath() -> String {
        let userDefaults = UserDefaults(suiteName: kSuitNameKey) ?? UserDefaults.standard
        let bundleResource = userDefaults.string(forKey: kBundleResourceKey) ?? "main"
        return sanboxPath() + "/" + kRollBackPrefixKey + bundleResource
    }
    
    // 解压
    class func unzip(_ sourcePath: String, _ destinationPath: String, _ progress: ((_ entry: String, _ entryNumber: Int, _ total: Int) -> Void)?, completion: ((_ path: String, _ success: Bool, _ error: Error?) -> Void)?) {
        guard destinationPath != "" else { return }
        DispatchQueue(label: "com.RNPush.unzip").async {
            if FileManager.default.fileExists(atPath: destinationPath) {
                try? FileManager.default.removeItem(atPath: destinationPath)
            }
            
            XPushLog("XPushManager unzip: \(sourcePath)  successed : \(destinationPath)")
            SSZipArchive.unzipFile(atPath: sourcePath, toDestination: destinationPath, progressHandler: { (entry, info, entryNumber, total) in
                DispatchQueue.main.async {
                    DispatchQueue.main.async {
                        XPushLog("XPushManager unzip progress: \(entry)   \(entryNumber)  \(total)")
                        progress?(entry, entryNumber, total)
                    }
                }
            }, completionHandler: { (path, successed, error) in
                DispatchQueue.main.async {
                    XPushLog("XPushManager unzip completion: \(path)   \(successed)  \(String(describing: error))")
                    completion?(path, successed, error)
                }
            })
        }
    }
    
    // 拷贝文件
    class func copy(_ sourcePath: String, _ destPath: String, _ complection: ((_ error: Error?) -> Void)? = nil) {
        DispatchQueue(label: "com.RNPush.copy").async {
            do {
                if FileManager.default.fileExists(atPath: destPath) {
                    try FileManager.default.removeItem(atPath: destPath)
                }
                try FileManager.default.copyItem(atPath: sourcePath, toPath: destPath)
                DispatchQueue.main.async {
                    complection?(nil)
                }
            } catch let error {
                DispatchQueue.main.async {
                    complection?(error)
                }
            }
        }
    }
    
    // 合并文件夹
    class func merge(_ sourceDir: String, _ destDir: String, _ deletes: [String] = [], _ completion: ((_ error: Error?) -> Void)? = nil) {
        DispatchQueue(label: "com.RNPush.merge").async {
            do {
                XPushLog("XPushManager merge: \(sourceDir)  --->  \(destDir)")
                var isSourceDirectory: ObjCBool = true
                var isDestDirectory: ObjCBool = true
                guard FileManager.default.fileExists(atPath: sourceDir, isDirectory: &isSourceDirectory), isSourceDirectory.boolValue else {
                    DispatchQueue.main.async {
                        completion?(NSError(domain: "com.RNPush", code: -1, userInfo: ["NSLocalizedFailureErrorKey": "sourceDir不是文件夹"]))
                    }
                    return
                }
                
                if !FileManager.default.fileExists(atPath: destDir, isDirectory: &isDestDirectory) {
                    try FileManager.default.createDirectory(atPath: destDir, withIntermediateDirectories: true, attributes: nil)
                }
                
                for deletePath in deletes {
                    let filePath = destDir + "/" + deletePath
                    if FileManager.default.fileExists(atPath: filePath) {
                        try FileManager.default.removeItem(atPath: filePath)
                    }
                }
                
                if FileManager.default.fileExists(atPath: sourceDir, isDirectory: &isSourceDirectory), isSourceDirectory.boolValue == true, let directoryEnumerator = FileManager.default.enumerator(atPath: sourceDir){
                    var subPath: String? = directoryEnumerator.nextObject() as? String
                    while subPath != nil {
                        let sourceFullPath = sourceDir.appending("/\(subPath!)")
                        let potentialDestFullPath = destDir.appending("/\(subPath!)")
                        
                        let isSourceExists = FileManager.default.fileExists(atPath: sourceFullPath, isDirectory: &isSourceDirectory)
                        let isDestExists = FileManager.default.fileExists(atPath: potentialDestFullPath, isDirectory: &isDestDirectory)
                        
                        if isSourceExists && isSourceDirectory.boolValue {
                            if !isDestExists {
                                try FileManager.default.createDirectory(atPath: potentialDestFullPath, withIntermediateDirectories: true, attributes: nil)
                            }
                        } else if isSourceExists {
                            if isDestExists && !isDestDirectory.boolValue {
                                try FileManager.default.removeItem(atPath: potentialDestFullPath)
                            }
                            try FileManager.default.copyItem(atPath: sourceFullPath, toPath: potentialDestFullPath)
                        }
                        subPath = directoryEnumerator.nextObject() as? String
                    }
                }
                
                DispatchQueue.main.async {
                    completion?(nil)
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion?(error)
                }
            }
        }
    }
}

/// MARK: manifest配置文件
extension XPushManager {
    
    // 检测路由是否有效
    class func validate(module: String, route: String) -> Bool {
        guard let model = RNManifestModel.model(for: module) else { return false }
        return model.routes.contains(route)
    }
    
    // 获取buildHash
    class func buildHash(for module: String) -> String {
        return RNManifestModel.model(for: module)?.buildHash ?? ""
    }
    
    class func buildHash(from url: URL) -> String {
        return RNManifestModel.model(from: url)?.buildHash ?? ""
    }
    
    // 获取所依赖的模块（目前来说所有包依赖于"Base"
    class func dependency(for module: String) -> [String] {
        return RNManifestModel.model(for: module)?.dependency ?? ["Base"]
    }
    
    // 获取manifest.json URL
    class fileprivate func manifestBundleURL(for module: String) -> URL? {
        return XPushManager.bundleURL()?.appendingPathComponent("\(module).manifest.json")
    }
    
    /// 配置文件
    fileprivate class RNManifestModel: NSObject {
        var appVersion: String = ""        // 当前发布的版本号
        var minAppVersion: String = ""     // 最小可使用的应用版本
        var buildHash: String = ""         // 模块构建后的hash值
        var routes: [String] = []          // 模块路由，用于检测路由是否可跳转
        var dependency: [String] = []      // 当前模块所依赖的其他模块
        
        static func model(for module: String) -> RNManifestModel? {
            guard let url = XPushManager.manifestBundleURL(for: module) else { return nil }
            return RNManifestModel.model(from: url)
        }
        
        static func model(from url: URL) -> RNManifestModel? {
            guard let data = try? Data(contentsOf: url), let json = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: Any] else { return nil }
            let model = RNManifestModel()
            model.appVersion = json["appVersion"] as? String ?? ""
            model.minAppVersion = json["minAppVersion"] as? String ?? ""
            model.buildHash = json["buildHash"] as? String ?? ""
            model.routes = json["routes"] as? [String] ?? []
            model.dependency = json["dependency"] as? [String] ?? []
            return model
        }
    }
}

/// MARK: 网络相关
extension XPushManager {
    
    class public func request(_ urlString: String, _ params: [String: Any]? = nil, _ httpMethod: String?, _ completion: ((Data?, URLResponse?, Error?) -> Void)?) {
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        request.httpMethod = httpMethod
        var httpBody = ""
        if let bodies = params {
            httpBody = bodies.reduce("") { (result, param) -> String in
                return "\(result)\(result == "" ? "" : "&")\(param.key)=\(param.value)"
            }
            request.httpBody = httpBody.data(using: .utf8)
        }
        XPushLog("XPushManager  request--request: \(urlString)     --   params : \(httpBody)")
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (data, response, error) in
            XPushLog("XPushManager  request--response:  \(response?.url?.path ?? "")   \(String(describing: data == nil ? "" : String(data: data!, encoding: String.Encoding.utf8)))  \n error: \(String(describing: error))")
            completion?(data, response, error)
        }
        task.resume()
    }
    
    class public func download(urlPath: String, save filePath: String?, progress: ((_ totalBytesWritten: Int64, _ totalBytesExpectedToWrite: Int64) -> Void)?, completion: ((_ path: String, _ error: Error?) -> Void)?) {
        var savePath = filePath
        if savePath == nil {
            savePath = XPushManager.sanboxPath()
        }
        
        RNPushDownloader.download(urlPath: urlPath, save: savePath!, progress: progress, completion: completion)
    }
    
}

/// MARK: 方法替换
extension XPushManager {
    
    class func swizzling(_ clazz: AnyClass, _ originalSelector: Selector, _ swizzledSelector: Selector) {
        if let originalMethod = class_getInstanceMethod(clazz, originalSelector), let swizzledMethod = class_getInstanceMethod(clazz, swizzledSelector) {
            if class_addMethod(clazz, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod)) {
                class_replaceMethod(clazz, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
    }
}

