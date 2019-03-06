//
//  XWeibo.swift
//  SwiftX
//
//  Created by wangcong on 2019/2/27.
//  Copyright © 2019 wangcong. All rights reserved.
//

import UIKit

final public class XWeibo: NSObject {
    
    public static let `default` = XWeibo()
    private override init() {}
    
    // 在调用前必须注册
    public func register(appKey: String) {
        WeiboSDK.enableDebugMode(true)
        WeiboSDK.registerApp(appKey)
    }
    
    public func isInstalled() -> Bool {
        return WeiboSDK.isWeiboAppInstalled()
    }
    
    public func handleOpen(url: URL) -> Bool {
        return WeiboSDK.handleOpen(url, delegate: self)
    }
    
    /// MARK: 登录
    public typealias AuthHandler = ((_ error: Error?, _ entity: AuthEntity?, _ jsonResponse: [AnyHashable: Any]) -> Void)
    private var authHandler: AuthHandler?

    /// MARK: 分享
    public typealias ShareHandler = ((Error?) -> Void)
    private var shareHandler: ShareHandler?
}

public extension XWeibo {
    
    public func auth(with handler: AuthHandler? = nil) {
        let authRequest = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        authRequest.scope = "all"
//        authRequest.redirectURI = MLConfiguration.ThirdPlatform.Sina.redirectURL
        authRequest.shouldShowWebViewForAuthIfCannotSSO = true
        WeiboSDK.send(authRequest)
    }
    
    final public class AuthEntity: NSObject, Codable {
        var openId: String?
        var nickName: String?
        var headImgUrl: String?
        var sex: Int?               // 0 男， 1女
        var province: String?
        var country: String?
        var unionid: String?
    }
    
}

extension XWeibo: WeiboSDKDelegate {
    
    public func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
        
    }
    
    public func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        if let response = response as? WBAuthorizeResponse {  // 登录
            
        }
    }
    
    
}

