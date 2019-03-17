//
//  XJPush.swift
//  SwiftX
//
//  Created by wangcong on 2019/3/7.
//

import UserNotifications

/// MARK: 极光推送封装，注意：3.0.0以上不再支持i386模拟器，需要将Build Active Architecture Only 设置为YES
final public class XJPush: NSObject {
    
    public static let `default` = XJPush()
    private override init() {}
    
    /// MARK: 注册回调, 如果 registrationID != nil 则注册成功
    public typealias RegisterHandler = ((_ registrationID: String?) -> Void)
    public var registrationID: String?   // 注册成功后此值存在，否则为nil
    
    // 在调用前必须注册
    public func register(appKey: String, launchOptions: [AnyHashable: Any], complection:((_ registrationID: String?) -> Void)? = nil) {
//        let entity = JPUSHRegisterEntity()
//        if #available(iOS 12.0, *) {
//            entity.types = Int(JPAuthorizationOptions(rawValue: JPAuthorizationOptions.alert.rawValue | JPAuthorizationOptions.badge.rawValue | JPAuthorizationOptions.sound.rawValue | JPAuthorizationOptions.providesAppNotificationSettings.rawValue).rawValue)
//        } else {
//            entity.types = Int(JPAuthorizationOptions(rawValue: JPAuthorizationOptions.alert.rawValue | JPAuthorizationOptions.badge.rawValue | JPAuthorizationOptions.sound.rawValue).rawValue)
//        }
//        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: nil)
//
//        var isProduction = false
//        #if !DEBUG
//        isProduction = true
//        #endif
//        JPUSHService.setup(withOption: launchOptions, appKey: appKey, channel: "Publish channel", apsForProduction: isProduction)
//        JPUSHService.registrationIDCompletionHandler { [weak self] (code, registrationID) in
//            if code == 0 {
//                self?.registrationID = registrationID
//                complection?(registrationID)
//                #if DEBUG
//                NSLog("com.SwiftX.OpenSDK.XJPush    registrationIDCompletionHandler   success  \(registrationID)")
//                #endif
//            } else {
//                #if DEBUG
//                NSLog("com.SwiftX.OpenSDK.XJPush    registrationIDCompletionHandler    fialure   \(code)")
//                #endif
//            }
//        }
    }
    
    public func register(deviceToken: Data) {
//        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    public func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
//        JPUSHService.handleRemoteNotification(userInfo)
    }
    
    public func showLocalNotificationAtFront(_ notification: UILocalNotification) {
//        JPUSHService.showLocalNotification(atFront: notification, identifierKey: nil)
    }
    
    public func handleOpen(url: URL) -> Bool {
        return true
    }

}

/// MARK: JPush tags
extension XJPush {
    
    public func addTags(_ tags: Set<String>, _ complection: ((_ iResCode: Int, _ iTags: Set<AnyHashable>?, _ seq: Int) -> Void)?, _ seq: Int = 0) {
//        JPUSHService.addTags(tags, completion: { (iResCode: Int, iTags: Set<AnyHashable>?, seq: Int) in
//            complection?(iResCode, iTags, seq)
//        }, seq: seq)
    }
    
    public func setTags(_ tags: Set<String>, _ complection: ((_ iResCode: Int, _ iTags: Set<AnyHashable>?, _ seq: Int) -> Void)?, _ seq: Int = 0) {
//        JPUSHService.setTags(tags, completion: { (iResCode: Int, iTags: Set<AnyHashable>?, seq: Int) in
//            complection?(iResCode, iTags, seq)
//        }, seq: seq)
    }
    
    public func deleteTags(_ tags: Set<String>, _ complection: ((_ iResCode: Int, _ iTags: Set<AnyHashable>?, _ seq: Int) -> Void)?, _ seq: Int = 0) {
//        JPUSHService.deleteTags(tags, completion: { (iResCode: Int, iTags: Set<AnyHashable>?, seq: Int) in
//            complection?(iResCode, iTags, seq)
//        }, seq: seq)
    }
    
    public func cleanTags(_ complection: ((_ iResCode: Int, _ iTags: Set<AnyHashable>?, _ seq: Int) -> Void)?, _ seq: Int = 0) {
//        JPUSHService.cleanTags({ (iResCode: Int, iTags: Set<AnyHashable>?, seq: Int) in
//            complection?(iResCode, iTags, seq)
//        }, seq: seq)
    }
    
    public func getAllTags(_ complection: ((_ iResCode: Int, _ iTags: Set<AnyHashable>?, _ seq: Int) -> Void)?, _ seq: Int = 0) {
//        JPUSHService.getAllTags({ (iResCode: Int, iTags: Set<AnyHashable>?, seq: Int) in
//            complection?(iResCode, iTags, seq)
//        }, seq: seq)
    }
    
}

/// MARK: Alias
extension XJPush {
    
    public func setAlias(_ alias: String, _ complection: ((_ iResCode: Int, _ iAlias: String?, _ seq: Int) -> Void)?, _ seq: Int = 0) {
//        JPUSHService.setAlias(alias, completion: { (iResCode, iAlias, seq) in
//            complection?(iResCode, iAlias, seq)
//        }, seq: seq)
    }
    
    public func deleteAlias(_ complection: ((_ iResCode: Int, _ iAlias: String?, _ seq: Int) -> Void)?, _ seq: Int = 0) {
//        JPUSHService.deleteAlias({ (iResCode, iAlias, seq) in
//            complection?(iResCode, iAlias, seq)
//        }, seq: seq)
    }
    
    public func getAlias(_ complection: ((_ iResCode: Int, _ iAlias: String?, _ seq: Int) -> Void)?, _ seq: Int = 0) {
//        JPUSHService.getAlias({ (iResCode, iAlias, seq) in
//            complection?(iResCode, iAlias, seq)
//        }, seq: seq)
    }
    
}

//extension XJPush: JPUSHRegisterDelegate {
//
//    @available(iOS 10.0, *)
//    public func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
//        let userInfo = notification.request.content.userInfo
//        if notification.request.trigger is UNPushNotificationTrigger {
//            JPUSHService.handleRemoteNotification(userInfo)
//        } else {
//            //本地通知
//        }
//        //需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
//        completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue))
//    }
//
//    @available(iOS 10.0, *)
//    public func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
//        let userInfo = response.notification.request.content.userInfo
//        if response.notification.request.trigger is UNPushNotificationTrigger {
//            JPUSHService.handleRemoteNotification(userInfo)
//        } else {
//            //本地通知
//        }
//        //处理通知 跳到指定界面等等
//        completionHandler()
//    }
//
//    @available(iOS 12.0, *)
//    public func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification?) {
//
//    }
//
//    // iOS 9.0
////    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
////        JPUSHService.handleRemoteNotification(userInfo);
////        completionHandler(UIBackgroundFetchResult.newData);
////    }
//
//}
