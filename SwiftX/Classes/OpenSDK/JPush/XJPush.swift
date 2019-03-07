//
//  XJPush.swift
//  SwiftX
//
//  Created by wangcong on 2019/3/7.
//

final public class XJPush: NSObject {
    
    public static let `default` = XJPush()
    private override init() {}
    
    /// MARK: 注册回调, 如果 registrationID != nil 则注册成功
    public typealias RegisterHandler = ((_ registrationID: String?) -> Void)
    public var registrationID: String?   // 注册成功后此值存在，否则为nil
    
    // 在调用前必须注册
    public func register(appKey: String, launchOptions: [AnyHashable: Any]) {
        let entity = JPUSHRegisterEntity()
        if #available(iOS 12.0, *) {
            entity.types = Int(JPAuthorizationOptions(rawValue: JPAuthorizationOptions.alert.rawValue | JPAuthorizationOptions.badge.rawValue | JPAuthorizationOptions.sound.rawValue | JPAuthorizationOptions.providesAppNotificationSettings.rawValue).rawValue)
        } else {
            entity.types = Int(JPAuthorizationOptions(rawValue: JPAuthorizationOptions.alert.rawValue | JPAuthorizationOptions.badge.rawValue | JPAuthorizationOptions.sound.rawValue).rawValue)
        }
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: nil)
       
        var isProduction = false
        #if !DEBUG
        isProduction = true
        #endif
        JPUSHService.setup(withOption: launchOptions, appKey: appKey, channel: "Publish channel", apsForProduction: isProduction)
        JPUSHService.registrationIDCompletionHandler { [weak self] (code, registrationID) in
            if code == 0 {
                self?.registrationID = registrationID
                #if DEBUG
                NSLog("com.SwiftX.OpenSDK.XJPush    registrationIDCompletionHandler   success  \(registrationID)")
                #endif
            } else {
                #if DEBUG
                NSLog("com.SwiftX.OpenSDK.XJPush    registrationIDCompletionHandler    fialure   \(code)")
                #endif
            }
        }
    }
    
    public func regiterDeviceToken(_ deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    public func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        JPUSHService.handleRemoteNotification(userInfo)
    }
    
    public func showLocalNotificationAtFront(_ notification: UILocalNotification) {
        JPUSHService.showLocalNotification(atFront: notification, identifierKey: nil)
    }
    
    public func handleOpen(url: URL) -> Bool {
        if url.host == "safepay" {
            AlipaySDK.defaultService()?.processOrder(withPaymentResult: url, standbyCallback: { (result) in
                print("XAlipay  handleOpen  ----   \(result)")
            })
            return true
        }
        return false
    }
    
}

//extension XJPush: JPUSHRegisterDelegate {
//
//    func jpushNotificationCenter(_ center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler:(void (^)(NSInteger))completionHandler {
//
//    }
//
//}
