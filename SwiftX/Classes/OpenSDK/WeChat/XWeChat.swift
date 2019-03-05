//
//  XWeChat.swift
//  SwiftX
//
//  Created by wangcong on 2019/2/27.
//  Copyright © 2019 wangcong. All rights reserved.
//

import UIKit

final public class XWeChat: NSObject {
    
    public static let `default` = XWeChat()
    private override init() {}
    
    // 在调用前必须注册
    public func register(appKey: String, appSecret: String) {
        WXApi.registerApp(appKey)
        UserDefaults.standard.set(appKey, forKey: "com.SwiftX.OpenSDK.WeChat.appKey")
        UserDefaults.standard.set(appSecret, forKey: "com.SwiftX.OpenSDK.WeChat.appSecret")
    }

    public func isInstalled() -> Bool {
        return WXApi.isWXAppInstalled() && WXApi.isWXAppSupport()
    }
    
    public func handleOpen(url: URL) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    /// MARK: 登录
    public typealias AuthHandler = ((Error?, AuthEntity?) -> Void)
    private var authHandler: AuthHandler?
    
    
    /// MARK: 支付
    public typealias PayHandler = ((Error?) -> Void)
    private var payHandler: PayHandler?
    
    // MARK: 分享
    public typealias ShareHandler = ((Error?) -> Void)
    private var shareHandler: ShareHandler?
}

// 登录
public extension XWeChat  {
    
    /// 授权第一步
    public func auth(with viewController: UIViewController, authHandler: AuthHandler? = nil) {
        self.authHandler = authHandler
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "123"
        WXApi.sendAuthReq(req, viewController: viewController, delegate: self)
    }
    
    /// 授权第二步
    private func _authToken(by code: String) {
        if let appKey = UserDefaults.standard.string(forKey: "com.SwiftX.OpenSDK.WeChat.appKey"), let appSecret = UserDefaults.standard.string(forKey: "com.SwiftX.OpenSDK.WeChat.appSecret") {
            let urlStr = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=\(appKey)&secret=\(appSecret)&code=\(code)&grant_type=authorization_code"
            let config = XHttp.Configuration(host: nil, method: .GET, requestSerializer: .none, responseSerializer: .json, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30, allowsCellularAccess: true, allHTTPHeaderFields: [:])
            XHttp.get(urlStr, .json, nil, config) { [weak self] (result) in
                guard let weakSelf = self else { return }
                switch result {
                case .success(let data):
                    if let dict = data as? [String: AnyObject], let token = dict["access_token"] as? String, let openId = dict["openid"] as? String {
                        weakSelf._authUserInfo(token: token, openId: openId)
                    } else {
                        weakSelf.authHandler?(NSError(domain: "com.SwiftX.OpenSDK.WeChat", code: Int(WechatAuth_Err_NormalErr.rawValue), description: "未注册appKey或者appSecret"), nil)
                    }
                case .failure(let error):
                    weakSelf.authHandler?(error, nil)
                }
            }
        } else {
            authHandler?(NSError(domain: "com.SwiftX.OpenSDK.WeChat", code: Int(WechatAuth_Err_NormalErr.rawValue), description: "未注册appKey或者appSecret"), nil)
        }
    }
    
    /// 第三步获取用户信息
    private func _authUserInfo(token: String, openId: String) {
        let urlStr = "https://api.weixin.qq.com/sns/userinfo?access_token=\(token)&openid=\(openId)"
        let config = XHttp.Configuration(host: nil, method: .GET, requestSerializer: .none, responseSerializer: .json, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30, allowsCellularAccess: true, allHTTPHeaderFields: [:])
        XHttp.get(urlStr, nil, nil, config) { [weak self] (result) in
            guard let weakSelf = self else { return }
            switch result {
            case .success(let data):
                if let entity = try? JSONDecoder.decode(AuthEntity.self, from: data) {
                    weakSelf.authHandler?(nil, entity)
                } else {
                    weakSelf.authHandler?(NSError(domain: "com.SwiftX.OpenSDK.WeChat", code: Int(WechatAuth_Err_NormalErr.rawValue), description: "解析用户信息失败"), nil)
                }
            case .failure(let error):
                weakSelf.authHandler?(error, nil)
            }
        }
    }
    
    final public class AuthEntity: NSObject, Codable {
        var openid: String?
        var nickname: String?
        var headImgUrl: String?
        var gender: Gender?
        var province: String?
        var city: String?
        var country: String?
        var unionid: String?
        
        enum CodingKeys: String, CodingKey {
            case openid
            case nickname
            case headImgUrl = "headimgurl"
            case gender = "sex"
            case province
            case city
            case country
            case unionid
        }
        
        enum Gender: Int {
            case unknown = -1
            case male = 1
            case female = 2
            
            var chineseDescription: String {
                switch self {
                case .male:
                    return "男"
                case .female:
                    return "女"
                default:
                    return "未知"
                }
            }
            
            var englishDescription: String {
                switch self {
                case .male:
                    return "male"
                case .female:
                    return "female"
                default:
                    return "unknown"
                }
            }
        }
        
        public init(from decoder: Decoder) throws {
            var container = try decoder.container(keyedBy: CodingKeys.self)
            openid = try container.decodeIfPresent(String.self, forKey: .openid)
            nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
            headImgUrl = try container.decodeIfPresent(String.self, forKey: .headImgUrl)
            let genderInt = try container.decodeIfPresent(Int.self, forKey: .gender)
            gender = Gender(rawValue: genderInt ?? -1) ?? .unknown
            province = try container.decodeIfPresent(String.self, forKey: .province)
            city = try container.decodeIfPresent(String.self, forKey: .city)
            country = try container.decodeIfPresent(String.self, forKey: .country)
            unionid = try container.decodeIfPresent(String.self, forKey: .unionid)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = try encoder.container(keyedBy: CodingKeys.self)
            try container.encode(openid, forKey: .openid)
            try container.encode(nickname, forKey: .nickname)
            try container.encode(headImgUrl, forKey: .headImgUrl)
            try container.encode(gender?.rawValue, forKey: .gender)
            try container.encode(province, forKey: .province)
            try container.encode(city, forKey: .city)
            try container.encode(country, forKey: .country)
            try container.encode(unionid, forKey: .unionid)
        }
        
    }
    
}

// 支付
extension XWeChat {
    
    public func pay(with params: [AnyHashable: Any], payHandler: PayHandler? = nil) {
        self.payHandler = payHandler
        let req = PayReq()
//        let timeStampString = orderDic["timestamp"] as! NSNumber
//        let timeStamp = timeStampString.uint32Value
//        req.partnerId           = "1318737301";
//        req.prepayId            = orderDic["prepayid"] as! String;
//        req.nonceStr            = orderDic["noncestr"] as! String;
//        req.timeStamp           = timeStamp;
//        req.package             = "Sign=WXPay";
//        req.sign                = orderDic["sign"] as! String;
        WXApi.send(req)
    }
    
}

// 分享
extension XWeChat {
    
    class Share: NSObject {
        
    }
    
}

extension XWeChat: WXApiDelegate {
    
    public func onReq(_ req: BaseReq) {
        
    }
    
    public func onResp(_ resp: BaseResp) {
        if let response = resp as? SendAuthResp {   // 三方认证
            if response.errCode == WXSuccess.rawValue {
                _authToken(by: response.code ?? "")
            } else {
                authHandler?(NSError(domain: "com.SwiftX.OpenSDK.WeChat", code: Int(response.errCode), description: response.errStr), nil)
            }
        } else if let response = resp as? PayResp {   // 支付
            if response.errCode == WXSuccess.rawValue {
                payHandler?(nil)
            } else {
                payHandler?(NSError(domain: "com.SwiftX.OpenSDK.WeChat", code: Int(response.errCode), description: response.errStr))
            }
        }
    }
    
}
