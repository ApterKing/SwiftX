//
//  XPushManager+ML.swift
//  Pods-MedCRM
//
//  Created by wangcong on 2018/11/26.
//

import Foundation

let check_lock = "check_lock"

/// MARK: ML拆包管理（公用方法-可供外部调用）
public extension XPushManager {
    
    /// MARK: 检查文件是否需要下载，注意每次调用下载某个某个模块之前一定要检查所依赖的模块是否已经被下载，如果未被下载则需下载
    class public func ml_updateIfNeeded(_ module: String, _ completion: ((_ shouldReloads: [String]?) -> Void)? = nil) {
        // 这里的modules 应当包含依赖的相关模块
        //        completion?(nil)
        var modules: [String] = []
        modules.append(contentsOf:XPushManager.dependency(for: module))
        modules.append(module)
        XPushManager.ml_checks(modules) { (_checkSuccess, _shouldReloads) in
            DispatchQueue.main.async {
                completion?(_checkSuccess ? _shouldReloads : nil)
                
                if _shouldReloads != nil {
                   XPushManager.preloadedBridge?.shouldReloadAfterAutomaticReferenceCountEqualZero = true
                }
                
                //                if let reloads = _shouldReloads {
                //                    if reloads.contains("Base") {
                //                       XPushManager.preloadedBridge?.shouldReloadAfterAutomaticReferenceCountEqualZero = true
                //                    }
                //                    if reloads.contains(module) {
                //                       XPushManager.preloadedBridge?.deleteModuleIfNeeded(module)
                //                    }
                //                }
            }
        }
    }
    
}

extensionXPushManager {
    
    // 保证同时检测、下载、解压、合并成功
    class fileprivate func ml_checks(_ modules: [String], _ completion: @escaping ((_ checkSuccess: Bool, _ shouldReloads: [String]?) -> Void)) {
        var _checkSuccesses: [Bool] = []
        var _shouldReloads: [String]?
        
        for module in modules {
           XPushManager.ml_check_pre(module) { (success, reload) in
                objc_sync_enter(check_lock)
                _checkSuccesses.append(success)
                
                if reload == true {
                    if _shouldReloads == nil {
                        _shouldReloads = []
                    }
                    _shouldReloads?.append(module)
                }
                
                if _checkSuccesses.count == modules.count {
                    let _checkSuccess = _checkSuccesses.filter({ $0 }).count == modules.count
                    completion(_checkSuccess, _shouldReloads)
                }
                objc_sync_exit(check_lock)
            }
        }
    }
    
    class fileprivate func ml_merge(_ module: String, _ completion: ((_ mergeSuccess: Bool) -> Void)? = nil) {
        let unpatchedPath = XPushManager.sanboxUnpatchedPath(for: module)
        let bundlePath = XPushManager.sanboxBundlePath()
        let rollbackPath = XPushManager.sanboxRollbackPath()
        
        // 如果当前的下载的版本存在线上bug则不能merge
        let url = URL(fileURLWithPath: unpatchedPath.appendingPathComponent("manifest.json"))
        let buildHash =XPushManager.buildHash(from: url)
        guard !RNPushManager.isBugBuildHash(for: buildHash) else {
           XPushManager.ml_clearInvalidate(module)
            completion?(false)
            return
        }
        
        // 在merge之前备份正常使用的module，用于后续merge或者热更出现错误回滚
       XPushManager.copy(bundlePath, rollbackPath) { (_) in
           XPushManager.merge(unpatchedPath, bundlePath, [], { (error) in
                let _mergeSuccess = error == nil
                if _mergeSuccess { // 合并成功清除不必要的文件
                    //                   XPushManager.ml_clearInvalidate(module)
                } else { // 否则则需要回滚该模块
                    try?XPushManager.rollback()
                }
                completion?(_mergeSuccess)
            })
        }
    }
    
    // 清除无用文件
    class fileprivate func ml_clearInvalidate(_ module: String) {
        DispatchQueue(label: "com.RNPush.ml_clearInvalidate").async {
            let unpatchedPath =XPushManager.sanboxUnpatchedPath(for: module)
            if FileManager.default.fileExists(atPath: unpatchedPath) {
                try? FileManager.default.removeItem(atPath: unpatchedPath)
            }
            
            let patchPath =XPushManager.sanboxPatchPath(for: module)
            if FileManager.default.fileExists(atPath: patchPath) {
                try? FileManager.default.removeItem(atPath: patchPath)
            }
        }
    }
}

/// MARK: 网络相关处理
extensionXPushManager {
    
    // 检测单个module是否需要重新reload;
    // completion parameter: checkSuccess 标识检测成功
    // completion parameter: shouldReload 标识是否需要重新加载
    class fileprivate func ml_check_pre(_ module: String, _ completion: @escaping ((_ checkSuccess: Bool, _ shouldReload: Bool) -> Void)) {
        // 检测更新前查看文件是否存在
        let destDir =XPushManager.sanboxBundlePath()
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: destDir, isDirectory: &isDirectory) || isDirectory.boolValue == false {
            let sourceDir =XPushManager.binaryBundleURL()?.path ?? ""
           XPushManager.copy(sourceDir, destDir, { (_) in
                ml_check(module, completion)
            })
        } else {
            ml_check(module, completion)
        }
    }
    
    class fileprivate func ml_check(_ module: String, _ completion: @escaping ((_ checkSuccess: Bool, _ shouldReload: Bool) -> Void)) {
        let config =XPushConfig(module)
        var params = config.ml_params()
        let buildHash =XPushManager.buildHash(for: module)
       XPushLog("RNPushManager  ml_check   module: \(module)  buildHash_pre:  \(buildHash)")
        params["buildHash"] = config.ml_encode(string: buildHash)
       XPushManager.request(config.serverUrl.appending(MLRNPushManagerApi.check), params, "POST") { (data, response, error) in
            if let err = error {
               XPushLog("RNPushManager ml_check error: \(module)  \(String(describing: err))")
                completion(false, false)
            } else {
                do {
                    if let json = (try JSONSerialization.jsonObject(with: data ?? Data(), options: .allowFragments)) as? [String: Any] {
                        let jsonCode = json["code"] as? Int64 ?? 0
                        let jsonData = json["data"] as? [String: Any] ?? [:]
                        if jsonCode != 0 {
                            completion(false, false)
                        } else {
                            let model = MLCheckModel.model(from: jsonData)
                            if model.shouldUpdate {
                               XPushManager.markStatus(for: module, buildHash: model.buildHash, status:XPushManagerStatus.pending)
                                // 下载
                               XPushManager.download(urlPath: model.url, save:XPushManager.sanboxPatchPath(for: module), progress: nil, completion: { (path, downloadError) in
                                    if downloadError != nil {
                                        completion(false, false)
                                    } else {
                                        // 解压
                                       XPushManager.unzip(RNPushManager.sanboxPatchPath(for: module),XPushManager.sanboxUnpatchedPath(for: module), nil, completion: { (zipPath, success, zipError) in
                                            if success {
                                                // 合并
                                               XPushManager.ml_merge(module, { (mergeSuccess) in
                                                    completion(mergeSuccess, mergeSuccess)
                                                })
                                            } else {
                                                completion(false, false)
                                            }
                                        })
                                    }
                                })
                            } else {
                               XPushLog("RNPushManager ml_check success: \(module)  已经是最新版本")
                                completion(true, false)
                            }
                        }
                    }
                } catch let error {
                   XPushLog("RNPushManager ml_check error catch: \(module)  \(String(describing: error))")
                    completion(false, false)
                }
            }
        }
    }
    
    // 请求所有模块，暂时未使用到
    class fileprivate func ml_all() {
        let config =XPushConfig("")
       XPushManager.request(config.serverUrl.appending(MLRNPushManagerApi.all), config.ml_params(), "POST") { (data, response, error) in
            
        }
    }
    
    class fileprivate func ml_success(_ module: String, _ buildHash: String, _ complection:((_ success: Bool) -> Void)? = nil) {
       XPushLog("RNPushManager  ml_success   module: \(module)  buildHash_pre:  \(buildHash)")
        let config =XPushConfig(module)
        var params = config.ml_params()
        params["buildHash"] = config.ml_encode(string: buildHash)
       XPushManager.request(config.serverUrl.appending(MLRNPushManagerApi.success), params, "POST") { (data, response, error) in
            complection?(error == nil)
        }
    }
    
    class fileprivate func ml_pending(_ module: String, _ buildHash: String, _ complection:((_ success: Bool) -> Void)? = nil) {
       XPushLog("RNPushManager  ml_pending   module: \(module)  buildHash_pre:  \(buildHash)")
        let config =XPushConfig(module)
        var params = config.ml_params()
        params["buildHash"] = config.ml_encode(string: buildHash)
       XPushManager.request(config.serverUrl.appending(MLRNPushManagerApi.pending), params, "POST") { (data, response, error) in
            complection?(error == nil)
        }
    }
    
    class fileprivate func ml_fail(_ module: String, _ buildHash: String, _ complection:((_ success: Bool) -> Void)? = nil) {
       XPushLog("RNPushManager  ml_fail   module: \(module)  buildHash_pre:  \(buildHash)")
        let config =XPushConfig(module)
        var params = config.ml_params()
        params["buildHash"] = config.ml_encode(string: buildHash)
       XPushManager.request(config.serverUrl.appending(MLRNPushManagerApi.fail), params, "POST") { (data, response, error) in
            complection?(error == nil)
        }
    }
    
    class public func ml_bind(_ userInfo: [String: Any]) {
       XPushLog("RNPushManager  ml_bind : \(userInfo)")
        let config =XPushConfig()
        var params: [String: Any] = config.ml_params()
        if let jsonData = try? JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted), let jsonString = String(data: jsonData, encoding: .utf8) {
            params["info"] = jsonString
        }
       XPushManager.request(config.serverUrl.appending(MLRNPushManagerApi.bind), params, "POST", nil)
    }
    
    fileprivate struct MLRNPushManagerApi {
        static let all = "/releases/buildhash/lastest/all"
        static let check = "/releases/checkUpdate"
        static let success = "/releases/update/success"
        static let pending = "/releases/update/pending"
        static let fail = "/releases/update/fail"
        static let bind = "/projects/bindDevice"
    }
    
    fileprivate class MLCheckModel: NSObject {
        var updated: Bool = true    // 是否为最新版本
        var force: Bool = false     // 是否需要强制更新
        var full: Bool = false      // 是否全量更新
        var url: String = ""        // 文件url
        var buildHash: String = ""  // hash值
        var module: String = ""     // 模块名称
        
        var shouldUpdate: Bool {
            get {
                return (force || !updated)
            }
        }
        
        static func model(from data: [String: Any]) -> MLCheckModel {
            let model = MLCheckModel()
            model.updated = data["updated"] as? Bool ?? true
            model.force = data["force"] as? Bool ?? false
            model.full = data["full"] as? Bool ?? false
            if let meta = data["meta"] as? [String: Any] {
                model.url = meta["url"] as? String ?? ""
                model.buildHash = meta["buildHash"] as? String ?? ""
            }
            return model
        }
    }
}

/// MARK: 配置一个监听器，处理:1、模块渲染成功 2、模块因状态改变需要进行网络的访问  3、用户登录状态发生改变
classXPushManagerMonitor: NSObject {
    
    static let `default` =XPushManagerMonitor()
    
    lazy var monitoring: Bool = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerNotification() {
        guard monitoring == false else { return }
        
        monitoring = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(contentDidAppearNotification(_:)), name: NSNotification.Name("RCTContentDidAppearNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeNotification(_:)), name: NSNotification.Name(RNPushManager.kModuleStatusKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loginStatusChanged(_:)), name: NSNotification.Name("newUserLogin"), object: nil)
    }
    
    @objc func contentDidAppearNotification(_ notification: NSNotification) {
        if let rootView = notification.object as? RCTRootView {
           XPushManager.removeRollbackIfNeeded(for: rootView.moduleName)
           XPushLog("RNPushManager ------- openRootView  moduleLoadSuccess  ----- end  xxx   \(rootView.moduleName)")
        }
    }
    
    @objc func didChangeNotification(_ notification: Notification) {
        DispatchQueue(label: "com.RNPushManager.monitor").async {
            if let userInfo = notification.userInfo, let module = userInfo["module"] as? String, let buildHash = userInfo["buildHash"] as? String, let status = userInfo["status"] as? Int64 {
                switch status {
                caseXPushManager.RNPushManagerStatus.pending:
                   XPushManager.ml_pending(module, buildHash, { (success) in
                        if success {
                           XPushManager.markStatus(for: module, buildHash: buildHash, status:XPushManager.RNPushManagerStatus.pending, shouldPostNotification: false)
                        }
                    })
                caseXPushManager.RNPushManagerStatus.success:
                   XPushManager.ml_success(module, buildHash, { (success) in
                        if success {
                           XPushManager.markStatus(for: module, buildHash: buildHash, status:XPushManager.RNPushManagerStatus.success, shouldPostNotification: false)
                        }
                    })
                default:
                   XPushManager.ml_fail(module, buildHash, { (success) in
                        if success {
                           XPushManager.markStatus(for: module, buildHash: buildHash, status:XPushManager.RNPushManagerStatus.fail, shouldPostNotification: false)
                        }
                    })
                }
            }
        }
    }
    
    @objc func loginStatusChanged(_ notification: NSNotification) {
        let userInfo : [String: Any] = [
            "name": MLLoginUser.shared.user?.name ?? "" ,
            "sectionName": MLLoginUser.shared.user?.sectionName ?? "",
            "titleName": MLLoginUser.shared.user?.titleName ?? "",
            "hospital": MLLoginUser.shared.user?.hospital ?? "",
            "sex": MLLoginUser.shared.user?.sex.rawValue ?? 0,
            "type": MLLoginUser.shared.user?.type?.rawValue ?? 0,
            "avatar": MLLoginUser.shared.user?.avatar ?? "",
            "id": MLLoginUser.shared.user?.userId ?? 0,
            "phoneNum": MLLoginUser.shared.user?.cellphone ?? ""
        ]
       XPushManager.ml_bind(userInfo)
    }
}

