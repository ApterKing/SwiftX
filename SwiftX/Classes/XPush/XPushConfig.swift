//
//  XPushConfig.swift
//  Swift-X
//
//  Created by wangcong on 2018/11/26.
//

import UIKit

class XPushConfig: NSObject {
    
    fileprivate struct XPushConfigKey {
        static let deploymentKeyConfigKey = "deploymentKey"
        static let appVersionConfigKey = "appVersion"
        static let buildVersionConfigKey = "buildVersion"
        static let clientUniqueIDConfigKey = "clientUniqueId"
        static let serverURLConfigKey = "serverUrl"
        static let publicKeyConfigKey = "publicKey"
        static let moduleConfigKey = "module"
    }
    
    fileprivate var configInfo: [String: Any] = [:]
    init(_ module: String = "") {
        super.init()
        self.module = module
        
        if let infoDictionary = Bundle.main.infoDictionary {
            deploymentKey = infoDictionary["XRNPushDeploymentKey"] as? String ?? ""
            appVersion = infoDictionary["CFBundleShortVersionString"] as? String ?? "1.0.0"
            buildVersion = infoDictionary["CFBundleVersion"] as? String ?? "1"
            serverUrl = infoDictionary["RNPushServerURL"] as? String ?? ""
            publicKey = infoDictionary["RNPushPublicKey"] as? String ?? ""
            
            let userDefaults = UserDefaults(suiteName: "RNPush") ?? UserDefaults.standard
            if deploymentKey == "" {
                deploymentKey = userDefaults.string(forKey: XPushConfigKey.deploymentKeyConfigKey) ?? ""
            }
            
            if serverUrl == "" {
                serverUrl = userDefaults.string(forKey: XPushConfigKey.serverURLConfigKey) ?? ""
            }
            
            var clientUniqueID = userDefaults.string(forKey: XPushConfigKey.clientUniqueIDConfigKey)
            if clientUniqueID == nil {
                clientUniqueID = UIDevice.current.identifierForVendor?.uuidString
                userDefaults.setValue(clientUniqueID!, forKey: XPushConfigKey.clientUniqueIDConfigKey)
            }
            clientUniqueId = clientUniqueID ?? ""
        }
    }
    
    var deploymentKey: String {
        get {
            return configInfo[XPushConfigKey.deploymentKeyConfigKey] as? String ?? ""
        }
        set {
            configInfo[XPushConfigKey.deploymentKeyConfigKey] = newValue
        }
    }
    
    var appVersion: String {
        get {
            return configInfo[XPushConfigKey.appVersionConfigKey] as? String ?? ""
        }
        set {
            configInfo[XPushConfigKey.appVersionConfigKey] = newValue
        }
    }
    
    var buildVersion: String {
        get {
            return configInfo[XPushConfigKey.buildVersionConfigKey] as? String ?? ""
        }
        set {
            configInfo[XPushConfigKey.buildVersionConfigKey] = newValue
        }
    }
    
    var clientUniqueId: String {
        get {
            return configInfo[XPushConfigKey.clientUniqueIDConfigKey] as? String ?? ""
        }
        set {
            configInfo[XPushConfigKey.clientUniqueIDConfigKey] = newValue
        }
    }
    
    var serverUrl: String {
        get {
            return configInfo[XPushConfigKey.serverURLConfigKey] as? String ?? ""
        }
        set {
            configInfo[XPushConfigKey.serverURLConfigKey] = newValue
        }
    }
    
    var publicKey: String {
        get {
            return configInfo[XPushConfigKey.publicKeyConfigKey] as? String ?? ""
        }
        set {
            configInfo[XPushConfigKey.publicKeyConfigKey] = newValue
        }
    }
    
    var module: String {
        get {
            return configInfo[XPushConfigKey.moduleConfigKey] as? String ?? ""
        }
        set {
            configInfo[XPushConfigKey.moduleConfigKey] = newValue
        }
    }
    
}

extension XPushConfig {
    
    static func register(serverUrl: String, deploymentKey: String) {
        let userDefaults = UserDefaults(suiteName: kSuitNameKey) ?? UserDefaults.standard
        userDefaults.setValue(serverUrl, forKey: XPushConfigKey.serverURLConfigKey)
        userDefaults.setValue(deploymentKey, forKey: XPushConfigKey.deploymentKeyConfigKey)
    }
    
}
