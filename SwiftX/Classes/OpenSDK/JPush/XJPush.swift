//
//  XJPush.swift
//  SwiftX
//
//  Created by wangcong on 2019/3/7.
//

import UserNotifications

/// MARK: 极光推送封装，注意：3.0.0以上不再支持i386模拟器，需要将Build Active Architecture Only 设置为YES
/// 并且在调用的地方判定:
/// #if !arch(i386)
/// #endif
final public class XJPush: NSObject {
    
    public static let `default` = XJPush()
    private override init() {}
    
    /// MARK: 注册回调, 如果 registrationID != nil 则注册成功
    public typealias RegisterHandler = ((_ registrationID: String?) -> Void)
    
    // 通知回调
    public typealias PresentHandler = ((_ request: UNNotificationRequest, _ isRemote: Bool) -> Void)
    
    // 响应通知回调
    public typealias ResponseHandler = ((_ request: UNNotificationResponse, _ isRemote: Bool) -> Void)
    
    private var presentHandler: PresentHandler?
    private var responseHandler: ResponseHandler?
    public var registrationID: String?   // 注册成功后此值存在，否则为nil

    // 在调用前必须注册
    public func register(appKey: String, launchOptions: [AnyHashable: Any], complection:((_ registrationID: String?) -> Void)? = nil) {
        #if !arch(i386)
        let entity = JPUSHRegisterEntity()
        if #available(iOS 12.0, *) {
            entity.types = Int(JPAuthorizationOptions(rawValue: JPAuthorizationOptions.alert.rawValue | JPAuthorizationOptions.badge.rawValue | JPAuthorizationOptions.sound.rawValue | JPAuthorizationOptions.providesAppNotificationSettings.rawValue).rawValue)
        } else {
            entity.types = Int(JPAuthorizationOptions(rawValue: JPAuthorizationOptions.alert.rawValue | JPAuthorizationOptions.badge.rawValue | JPAuthorizationOptions.sound.rawValue).rawValue)
        }
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)

        var isProduction = false
        #if !DEBUG
        isProduction = true
        #endif
        JPUSHService.setup(withOption: launchOptions, appKey: appKey, channel: "Publish channel", apsForProduction: isProduction)
        JPUSHService.registrationIDCompletionHandler { [weak self] (code, registrationID) in
            if code == 0 {
                self?.registrationID = registrationID
                complection?(registrationID)
                #if DEBUG
                NSLog("com.SwiftX.OpenSDK.XJPush    registrationIDCompletionHandler   success  \(registrationID)")
                #endif
            } else {
                #if DEBUG
                NSLog("com.SwiftX.OpenSDK.XJPush    registrationIDCompletionHandler    fialure   \(code)")
                #endif
            }
        }
        #endif
    }
    
    public func setHandler(presentHandler: PresentHandler? = nil, responseHandler: ResponseHandler? = nil) {
        self.presentHandler = presentHandler
        self.responseHandler = responseHandler
    }
    
    public func register(deviceToken: Data) {
        #if !arch(i386)
        JPUSHService.registerDeviceToken(deviceToken)
        #endif
    }
    
    public func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        #if !arch(i386)
        JPUSHService.handleRemoteNotification(userInfo)
        #endif
    }
    
    public func showLocalNotificationAtFront(_ notification: UILocalNotification) {
        #if !arch(i386)
        JPUSHService.showLocalNotification(atFront: notification, identifierKey: nil)
        #endif
    }
    
    public func handleOpen(url: URL) -> Bool {
        return true
    }

}

/// MARK: JPush tags
extension XJPush {
    
    public func addTags(_ tags: Set<String>, _ complection: ((_ iResCode: Int, _ iTags: Set<AnyHashable>?, _ seq: Int) -> Void)?, _ seq: Int = 0) {
        #if !arch(i386)
        JPUSHService.addTags(tags, completion: { (iResCode: Int, iTags: Set<AnyHashable>?, seq: Int) in
            complection?(iResCode, iTags, seq)
        }, seq: seq)
        #endif
    }
    
    public func setTags(_ tags: Set<String>, _ complection: ((_ iResCode: Int, _ iTags: Set<AnyHashable>?, _ seq: Int) -> Void)?, _ seq: Int = 0) {
        #if !arch(i386)
        JPUSHService.setTags(tags, completion: { (iResCode: Int, iTags: Set<AnyHashable>?, seq: Int) in
            complection?(iResCode, iTags, seq)
        }, seq: seq)
        #endif
    }
    
    public func deleteTags(_ tags: Set<String>, _ complection: ((_ iResCode: Int, _ iTags: Set<AnyHashable>?, _ seq: Int) -> Void)?, _ seq: Int = 0) {
        #if !arch(i386)
        JPUSHService.deleteTags(tags, completion: { (iResCode: Int, iTags: Set<AnyHashable>?, seq: Int) in
            complection?(iResCode, iTags, seq)
        }, seq: seq)
        #endif
    }
    
    public func cleanTags(_ complection: ((_ iResCode: Int, _ iTags: Set<AnyHashable>?, _ seq: Int) -> Void)?, _ seq: Int = 0) {
        #if !arch(i386)
        JPUSHService.cleanTags({ (iResCode: Int, iTags: Set<AnyHashable>?, seq: Int) in
            complection?(iResCode, iTags, seq)
        }, seq: seq)
        #endif
    }
    
    public func getAllTags(_ complection: ((_ iResCode: Int, _ iTags: Set<AnyHashable>?, _ seq: Int) -> Void)?, _ seq: Int = 0) {
        #if !arch(i386)
        JPUSHService.getAllTags({ (iResCode: Int, iTags: Set<AnyHashable>?, seq: Int) in
            complection?(iResCode, iTags, seq)
        }, seq: seq)
        #endif
    }
    
}

/// MARK: Alias
extension XJPush {
    
    public func setAlias(_ alias: String, _ complection: ((_ iResCode: Int, _ iAlias: String?, _ seq: Int) -> Void)?, _ seq: Int = 0) {
        #if !arch(i386)
        JPUSHService.setAlias(alias, completion: { (iResCode, iAlias, seq) in
            complection?(iResCode, iAlias, seq)
        }, seq: seq)
        #endif
    }
    
    public func deleteAlias(_ complection: ((_ iResCode: Int, _ iAlias: String?, _ seq: Int) -> Void)?, _ seq: Int = 0) {
        #if !arch(i386)
        JPUSHService.deleteAlias({ (iResCode, iAlias, seq) in
            complection?(iResCode, iAlias, seq)
        }, seq: seq)
        #endif
    }
    
    public func getAlias(_ complection: ((_ iResCode: Int, _ iAlias: String?, _ seq: Int) -> Void)?, _ seq: Int = 0) {
        #if !arch(i386)
        JPUSHService.getAlias({ (iResCode, iAlias, seq) in
            complection?(iResCode, iAlias, seq)
        }, seq: seq)
        #endif
    }
    
}

#if !arch(i386)
extension XJPush: JPUSHRegisterDelegate {

    @available(iOS 10.0, *)
    public func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        let request = notification.request
        let userInfo = notification.request.content.userInfo
        let content = request.content
        let badge = content.badge  // 推送消息角标
        let body = content.body  // 推送消息实体
        let sound = content.sound  // 推送消息角标
        let subtitle = content.subtitle  // 推送消息主标题
        let title = content.title  // 推送消息副标题

        if notification.request.trigger is UNPushNotificationTrigger {
            JPUSHService.handleRemoteNotification(userInfo)
            print("XJPush fuck   收到远程通知   \(badge)  \(body)   \(userInfo)")
            presentHandler?(request, true)
            completionHandler(Int(UNNotificationPresentationOptions(rawValue: UNNotificationPresentationOptions.badge.rawValue | UNNotificationPresentationOptions.sound.rawValue | UNNotificationPresentationOptions.alert.rawValue).rawValue))
        } else {
            //本地通知
            presentHandler?(request, false)
            print("XJPush fuck   收到本地通知   \(badge)  \(body)    \(userInfo)")
            completionHandler(Int(UNNotificationPresentationOptions(rawValue: UNNotificationPresentationOptions.sound.rawValue | UNNotificationPresentationOptions.alert.rawValue).rawValue))
        }
    }

    @available(iOS 10.0, *)
    public func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        let userInfo = response.notification.request.content.userInfo
        if response.notification.request.trigger is UNPushNotificationTrigger {
            JPUSHService.handleRemoteNotification(userInfo)
            print("XJPush fuck  response  收到远程通知   \(userInfo)")
            responseHandler?(response, true)
        } else {
            //本地通知
            responseHandler?(response, false)
            print("XJPush fuck  response  收到本地通知   \(userInfo)")
        }
        
        //处理通知 跳到指定界面等等
        completionHandler()
    }

    @available(iOS 12.0, *)
    public func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification?) {
//        NSString *title = nil;
//        if (notification) {
//            title = @"从通知界面直接进入应用";
//        }else{
//            title = @"从系统设置界面进入应用";
//        }
//        UIAlertView *test = [[UIAlertView alloc] initWithTitle:title
//            message:@"pushSetting"
//            delegate:self
//            cancelButtonTitle:@"yes"
//            otherButtonTitles:nil, nil];
//        [test show];
    }

}
#endif
