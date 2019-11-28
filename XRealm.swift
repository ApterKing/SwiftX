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
   Realm数据库封装
   - initialize 需要在启动时配置数据库，如果数据库根据某个特定情况不同，如：用户的id变化而初始化不同数据库，那么需要在情况发生变化时重新初始化一次
   - add/update/delete 新增修改数据：可通过autoWrite = true 在add/update/delete时将会在transaction中提交所做操作
   上述方法最大程度避免重复beginTransaction导致程序崩溃

   - Usage:
     - 初始化：只有初始化之后才能使用Realm数据库，这里的UID可以为空，那么会自动创建一个UID相关的数据库URL
       XRealm.default.initialize(withUID: "xxx")

     - 数据库操作：
       XRealm.default.add(object, true/false, true)

     - 如果在同一地方多次调用add/update/delete/select建议：
       if let realm = XRealm.default.realm {
           XRealm.default.write {
               // do something
               realm.add(object, true/false)
               ...
           }
       }
 
     - 主线程下支持事务嵌套观察
        var token: NotificationToken?
        try? realm0.write {
            realm0.add(book, update: true)
            XRealm.default.observe(book, { (change) in
                print("观察变更   \(change)")
            }, { [weak self] (token, error) in
                self?.token = token
            })
        }

     - 非主线程下不支持事务嵌套观察，但你可以这样做
        var token: NotificationToken?
        XRealm.default.add(book, update: true)
        XRealm.default.observe(book, { (change) in
            print("观察变更   \(change)")
        }, { [weak self] (token, error) in
            self?.token = token
        })
 */
public class XRealm: NSObject {

    static public let `default` = XRealm()
    fileprivate override init() {}

    /// 由于Realm数据库时线程非安全，并且不支持跨线程贡献，那么我们必须为每个线程Realm实例时
    /// 如果增、删、改、查时在主线程，就不会新建realm，否则会在运行的线程新建一个realm，故不必担忧在增删改查时跨线程操作的问题
    public var realm: Realm? {
        get {
            if Thread.isMainThread {
                return _realm ?? (try? Realm())
            } else {
                return try? Realm()
            }
        }
    }
    fileprivate var _realm: Realm?
    fileprivate var lock = NSRecursiveLock()

    /// warning: UID、inMemoryIdentifier、syncConfiguration 三者只能存在其一
    public func initialize(withUID: String? = nil,
                           inMemoryIdentifier: String? = nil,
                           syncConfiguration: SyncConfiguration? = nil,
                           encryptionKey: Data? = nil,
                           readOnly: Bool = false,
                           schemaVersion: UInt64 = 1,
                           migrationBlock: MigrationBlock? = nil,
                           deleteRealmIfMigrationNeeded: Bool = true,
                           shouldCompactOnLaunch: ((Int, Int) -> Bool)? = nil,
                           objectTypes: [Object.Type]? = nil) throws {

        var fileURL: URL?
        if inMemoryIdentifier == nil && syncConfiguration == nil {
            fileURL = withUID != nil && withUID != "" ? XRealm.sanboxURL(withUID!) : XRealm.sanboxURL(XRealm.UUID())
        }

        let configuration = Realm.Configuration(fileURL: fileURL,
                                                inMemoryIdentifier: inMemoryIdentifier ?? (fileURL == nil && syncConfiguration == nil ? "XRealm" : nil),
                                                syncConfiguration: syncConfiguration,
                                                encryptionKey: encryptionKey,
                                                readOnly: readOnly,
                                                schemaVersion: schemaVersion,
                                                migrationBlock: migrationBlock,
                                                deleteRealmIfMigrationNeeded: deleteRealmIfMigrationNeeded,
                                                shouldCompactOnLaunch: shouldCompactOnLaunch,
                                                objectTypes: objectTypes)

        try self.initialize(configuration: configuration)
    }

    // 使用configuration配置
    public func initialize(configuration: Realm.Configuration) throws {
        lock.lock()
        // 保证数据库处理完毕后才打开，并且保证默认持有的一个Realm实例在主线程上
        Realm.asyncOpen(configuration: configuration, callbackQueue: DispatchQueue.main, callback: { [weak self] (realm, error) in
            Realm.Configuration.defaultConfiguration = configuration
            self?._realm = realm
            self?.lock.unlock()
        })
    }

}

/// MARK: 事务操作
extension XRealm {

    // 在同一个Realm实例中或者相同线程下的不同Realm实例中不支持事务嵌套操作
    // 虽然这种事务嵌套应该极力避免，但在团队合作开发室这种情况难免会出现
    public func write(_ realm: Realm? = nil, _ block: (() throws -> Void)) throws {
        guard let realm = realm ?? self.realm else { return }
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

    // 有效避免操作已经invalidate的数据
    public func add(_ object: Object, _ update: Bool = false, _ autoWrite: Bool = true) {
        guard let realm = object.realm ?? self.realm, !object.isInvalidated else { return }
        guard autoWrite == true else {
            realm.add(object, update: update)
            return
        }
        // 这里更多请查看上述：事务操作
        try? write(realm, {
            realm.add(object, update: update)
        })
    }

    public func add<S: Sequence>(_ objects: S, update: Bool = false, _ autoWrite: Bool = true) where S.Iterator.Element: Object {
        guard let realm = self.realm else { return }
        let newObjects: [Object] = objects.filter { (object) -> Bool in
            return !object.isInvalidated
        }
        guard newObjects.count != 0 else { return }
        guard autoWrite == true else {
            realm.add(objects, update: update)
            return
        }
        try? write(realm, {
            realm.add(objects, update: update)
        })
    }

}

/// MARK: 删除数据
extension XRealm {

    // 有效避免操作已经invalidate的数据
    public func delete(_ object: Object, _ autoWrite: Bool = true) {
        guard let realm = object.realm ?? self.realm, !object.isInvalidated  else { return }
        guard autoWrite == true else {
            realm.delete(object)
            return
        }
        try? write(realm, {
            realm.delete(object)
        })
    }

    public func delete<S: Sequence>(_ objects: S, _ autoWrite: Bool = true) where S.Iterator.Element: Object {
        guard let realm = self.realm else { return }
        let newObjects: [Object] = objects.filter { (object) -> Bool in
            return !object.isInvalidated
        }
        guard newObjects.count != 0 else { return }
        guard autoWrite == true else {
            realm.delete(newObjects)
            return
        }
        try? write(realm, {
            realm.delete(newObjects)
        })
    }

    public func delete<Element: Object>(_ objects: List<Element>, _ autoWrite: Bool = true) {
        guard let realm = objects.realm ?? self.realm, !objects.isInvalidated  else { return }
        guard autoWrite == true else {
            realm.delete(objects)
            return
        }
        try? write(realm, {
            realm.delete(objects)
        })
    }

    public func delete<Element: Object>(_ objects: Results<Element>, _ autoWrite: Bool = true) {
        guard let realm = objects.realm ?? self.realm, !objects.isInvalidated  else { return }
        guard autoWrite == true else {
            realm.delete(objects)
            return
        }
        try? write(realm, {
            realm.delete(objects)
        })
    }

    public func deleteAll(_ autoWrite: Bool = true) {
        guard autoWrite == true else {
            realm?.deleteAll()
            return
        }
        try? write(realm, {
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

/// MARK: 观察
extension XRealm {

    public typealias ObserverHandler = ((_ token: NotificationToken?, _ error: ObserveError?) -> Void)
    public typealias ObjectBlock = ((ObjectChange) -> Void)

    public enum ObserveError: Error {
        case unmanagedError   // 对象未被Realm实例managed，不可observe
        case threadSafeError  // 除了主线程外，其他线程允许观察，但不允许在事务中观察
    }

    // 事务中观察Object
    public func observe<Element: Object>(_ object: Element, _ block: @escaping ((ObjectChange) -> Void), _ handler: @escaping ObserverHandler) {
        guard object.realm != nil else {
            handler(nil, .unmanagedError)
            return
        }
        guard self.realm?.isInWriteTransaction == false else {
            if Thread.isMainThread {
                _runloopPerformBlock { [weak self] in
                    self?.observe(object, block, handler)
                }
            } else {
                handler(nil, .threadSafeError)
            }
            return
        }
        _runloopPerformBlock {
            let token = object.observe(block)
            handler(token, nil)
        }
    }

    // 观察Results
    public func observe<Element: Object>(_ results: Results<Element>, _ block: @escaping ((RealmCollectionChange<Results<Element>>) -> Void), _ handler: @escaping ObserverHandler) {
        guard results.realm != nil else {
            handler(nil, .unmanagedError)
            return
        }
        guard self.realm?.isInWriteTransaction == false else {
            if Thread.isMainThread {
                _runloopPerformBlock { [weak self] in
                    self?.observe(results, block, handler)
                }
            } else {
                handler(nil, .threadSafeError)
            }
            return
        }
        _runloopPerformBlock {
            let token = results.observe(block)
            handler(token, nil)
        }
    }

    // 观察List
    public func observe<Element: Object>(_ list: List<Element>, _ block: @escaping ((RealmCollectionChange<List<Element>>) -> Void), _ handler: @escaping ObserverHandler) {
        guard list.realm != nil else {
            handler(nil, .unmanagedError)
            return
        }
        guard self.realm?.isInWriteTransaction == false else {
            if Thread.isMainThread {
                _runloopPerformBlock { [weak self] in
                    self?.observe(list, block, handler)
                }
            } else {
                handler(nil, .threadSafeError)
            }
            return
        }
        _runloopPerformBlock {
            let token = list.observe(block)
            handler(token, nil)
        }
    }

    // 观察LinkingObjects
    public func observe<Element: Object>(_ linkings: LinkingObjects<Element>, _ block: @escaping ((RealmCollectionChange<LinkingObjects<Element>>) -> Void), _ handler: @escaping ObserverHandler) {
        guard linkings.realm != nil else {
            handler(nil, .unmanagedError)
            return
        }
        guard self.realm?.isInWriteTransaction == false else {
            if Thread.isMainThread {
                _runloopPerformBlock { [weak self] in
                    self?.observe(linkings, block, handler)
                }
            } else {
                handler(nil, .threadSafeError)
            }
            return
        }
        _runloopPerformBlock {
            let token = linkings.observe(block)
            handler(token, nil)
        }
    }

    private func _runloopPerformBlock(_ block: @escaping (() -> Void)) {
        CFRunLoopPerformBlock(CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue) {
            block()
        }
        if !Thread.isMainThread {
            CFRunLoopRun()
        }
    }

}

/// MARK: Realm文件路径
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
