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
    public var accessToken: String?
    public var uid: String?
    
    /** MARK: 登录回调
     *  @param  error: 错误
     *  @param  entity: 解析后的数据
     *  @param  jsonResponse: 未解析的数据
     */
    public typealias AuthHandler = ((_ error: Error?, _ entity: AuthEntity?, _ jsonResponse: [AnyHashable: Any]?) -> Void)
    private var authHandler: AuthHandler?
    
    /// MARK: 分享
    public typealias ShareHandler = ((Error?) -> Void)
    private var shareHandler: ShareHandler?
    
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
    
}

/// MARK: 认证
public extension XWeibo {
    
    public func auth(with redirectURI: String = "https://api.weibo.com/oauth2/default.html", handler: AuthHandler? = nil) {
        self.authHandler = handler
        let authRequest = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        authRequest.scope = "all"
        authRequest.redirectURI = redirectURI
        authRequest.shouldShowWebViewForAuthIfCannotSSO = true
        WeiboSDK.send(authRequest)
    }
    
    final public class AuthEntity: NSObject, Codable {
        var uid: Int64
        var nicame: String?
        var sex: String?               // 1：男、2：女、0：未知
        var city: String?
        var country: String?
        var province: String?
        var headimgurl: String?
        var headimgurl_large: String?
        var headimgurl_hd: String?
    }
    
}

extension XWeibo: WeiboSDKDelegate {
    
    public func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
        
    }
    
    public func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        if let response = response as? WBAuthorizeResponse {  // 登录
            if response.statusCode == WeiboSDKResponseStatusCode.success {
                accessToken = response.accessToken!
                uid = response.userID!
                WBHttpRequest(accessToken: accessToken!, url: "https://api.weibo.com/2/users/show.json", httpMethod: "GET", params: ["access_token": accessToken!, "uid": uid!], delegate: self, withTag: "auth")
            } else {
                authHandler?(NSError(domain: "com.SwiftX.OpenSDK.Weibo", code: response.statusCode.rawValue, description: "微博授权失败"), nil, nil)
            }
        }
    }
    
}

extension XWeibo: WBHttpRequestDelegate {
    
    public func request(_ request: WBHttpRequest!, didFailWithError error: Error!) {
        if request.tag == "auth" {
            authHandler?(NSError(domain: "com.SwiftX.OpenSDK.Weibo", code: -1, description: error.localizedDescription), nil, nil)
        }
    }
    
    public func request(_ request: WBHttpRequest!, didFinishLoadingWithDataResult data: Data!) {
        if request.tag == "auth" {
            let entity = try? JSONDecoder.decode(AuthEntity.self, from: data)
            let jsonResponse = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [AnyHashable: Any]
            authHandler?(nil, entity, jsonResponse)
        }
    }
}

