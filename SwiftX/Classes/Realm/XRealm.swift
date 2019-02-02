//
//  XRealm.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/18.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

/**
 *  Realm数据库封装
 *  - initialize 需要在启动时配置数据库，如果数据库根据某个特定情况不同，如：用户的id变化而初始化不同数据库，那么需要在情况发生变化时重新初始化一次
 *  - add/update/delete 新增修改数据：可通过autoWrite = true 在add/update/delete时将会在transaction中提交所做操作
 *  上述方法最大程度避免重复beginTransaction导致程序崩溃
 *
 *  - Usage:
 *    - 初始化：只有初始化之后才能使用Realm数据库
 *      XRealm.default.initialize(withUID: "xxx")
 *
 *    - 数据库操作：
 *      XRealm.default.add(object, true/false, true)
 *
 *    - 如果在同一地方多次调用add/update/delete/select建议：
 *      if let realm = XRealm.default.realm {
 *          XRealm.default.write {
 *              // do something
 *              realm.add(object, true/false)
 *              ...
 *          }
 *      }
 */
public class XRealm {
    
    static public let `default` = XRealm()
    
    public var realm: Realm?
    fileprivate var configuration: Realm.Configuration? = nil {
        didSet {
            if let config = configuration, let realm = try? Realm(configuration: config) {
                realm.refresh()
                self.realm = realm
            }
        }
    }
    fileprivate var lock = NSRecursiveLock()
    
    fileprivate init() {}
    
    public func initialize(withUID: String?,
                           inMemoryIdentifier: String? = nil,
                           syncConfiguration: SyncConfiguration? = nil,
                           encryptionKey: Data? = nil,
                           readOnly: Bool = false,
                           schemaVersion: UInt64 = 1,
                           migrationBlock: MigrationBlock? = nil,
                           deleteRealmIfMigrationNeeded: Bool = true,
                           shouldCompactOnLaunch: ((Int, Int) -> Bool)? = nil,
                           objectTypes: [Object.Type]? = nil) throws {
        
        var fileURL = XRealm.sanboxURL(XRealm.UUID())
        if withUID != nil && withUID != "" {
            fileURL = XRealm.sanboxURL(withUID!)
        }
        
        let config = Realm.Configuration(fileURL: fileURL,
                                         inMemoryIdentifier: inMemoryIdentifier ?? (fileURL == nil ? "XRealm" : nil),
                                         syncConfiguration: syncConfiguration,
                                         encryptionKey: encryptionKey,
                                         readOnly: readOnly,
                                         schemaVersion: schemaVersion,
                                         migrationBlock: migrationBlock,
                                         deleteRealmIfMigrationNeeded: deleteRealmIfMigrationNeeded,
                                         shouldCompactOnLaunch: shouldCompactOnLaunch,
                                         objectTypes: objectTypes)
        
        lock.lock()
        do {
            Realm.Configuration.defaultConfiguration = config
            _ = try Realm(configuration: config)
            configuration = config
            lock.unlock()
        } catch let error {
            lock.unlock()
            throw NSError(domain: "com.swiftx.XRealm", code: -1, userInfo: ["XRealm": "Failed to init Realm with configuration \(config), error \(error)"])
        }
    }
    
    public func write(_ block: (() throws -> Void)) throws {
        guard let realm = self.realm else { return }
        var markedShouldCommit = false
        if !realm.isInWriteTransaction {
            realm.beginWrite()
            markedShouldCommit = true
        }
        do {
            try block()
        } catch let error {
            if markedShouldCommit && realm.isInWriteTransaction {
                realm.cancelWrite()
            }
            throw error
        }
        if markedShouldCommit && realm.isInWriteTransaction {
            try realm.commitWrite()
        }
    }
    
}

/// MARK: 新增/修改数据
extension XRealm {
    
    public func add(_ object: Object, _ update: Bool = false, _ autoWrite: Bool = true) {
        guard let realm = self.realm, !object.isInvalidated else { return }
        guard autoWrite == true else {
            realm.add(object, update: update)
            return
        }
        try? write({
            realm.add(object, update: update)
        })
    }
    
    public func add<S: Sequence>(_ objects: S, update: Bool = false, _ autoWrite: Bool = true) where S.Iterator.Element: Object {
        guard let realm = self.realm else { return }
        var newObjects: [Object] = []
        for object in objects {
            if !object.isInvalidated {
                newObjects.append(object)
            }
        }
        if newObjects.count != 0 {
            guard autoWrite == true else {
                realm.add(objects, update: update)
                return
            }
            try? write({
                realm.add(objects, update: update)
            })
        }
    }
    
}

/// MARK: 删除数据
extension XRealm {
    
    public func delete(_ object: Object, _ autoWrite: Bool = true) {
        guard let realm = self.realm, !object.isInvalidated  else { return }
        guard autoWrite == true else {
            realm.delete(object)
            return
        }
        try? write({
            realm.delete(object)
        })
    }
    
    public func delete<S: Sequence>(_ objects: S, _ autoWrite: Bool = true) where S.Iterator.Element: Object {
        guard let realm = self.realm else { return }
        var newObjects: [Object] = []
        for object in objects {
            if !object.isInvalidated {
                newObjects.append(object)
            }
        }
        if newObjects.count != 0 {
            guard autoWrite == true else {
                realm.delete(newObjects)
                return
            }
            try? write({
                realm.delete(newObjects)
            })
        }
    }
    
    public func delete<Element: Object>(_ objects: List<Element>, _ autoWrite: Bool = true) {
        guard let realm = self.realm, !objects.isInvalidated  else { return }
        guard autoWrite == true else {
            realm.delete(objects)
            return
        }
        try? write({
            realm.delete(objects)
        })
    }
    
    public func delete<Element: Object>(_ objects: Results<Element>, _ autoWrite: Bool = true) {
        guard let realm = self.realm, !objects.isInvalidated  else { return }
        guard autoWrite == true else {
            realm.delete(objects)
            return
        }
        try? write({
            realm.delete(objects)
        })
    }
    
    public func deleteAll(_ autoWrite: Bool = true) {
        guard autoWrite == true else {
            realm?.deleteAll()
            return
        }
        try? write({
            realm?.deleteAll()
        })
    }
    
}

/// MARK: 查询数据
extension XRealm {
    
    public func objects<Element: Object>(_ type: Element.Type) -> Results<Element>? {
        return realm?.objects(type)
    }
    
    public func object<Element: Object, KeyType>(ofType type: Element.Type, forPrimaryKey key: KeyType) -> Element? {
        return realm?.object(ofType: type, forPrimaryKey: key)
    }
    
}

extension XRealm {
    
    public static func sanboxURL(_ pathComponent: String, _ ofType: String = "realm") -> URL? {
        if let supportPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            let sanboxPath = "\(supportPath)/\(pathComponent).\(ofType)"
            #if DEBUG
            NSLog("XRealm path: \(sanboxPath)")
            #endif
            return URL(fileURLWithPath: sanboxPath)
        }
        return nil
    }
    
    public static func UUID() -> String {
        let userDefault = UserDefaults(suiteName: "Swift-X") ?? UserDefaults.standard
        if let uuid = userDefault.string(forKey: "XRealmManager_UUID") {
            return uuid
        } else {
            let uuid = UIDevice.current.identifierForVendor?.uuidString ?? "swift-x-xrealm-manager"
            userDefault.set(uuid, forKey: "XRealmManager_UUID")
            return uuid
        }
    }
    
}

