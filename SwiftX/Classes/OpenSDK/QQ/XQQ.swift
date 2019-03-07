//
//  XQQ.swift
//  SwiftX
//
//  Created by wangcong on 2019/2/27.
//  Copyright © 2019 wangcong. All rights reserved.
//

final public class XQQ: NSObject {
    
    public static let `default` = XQQ()
    private override init() {}
    
    /** MARK: 登录回调
     *  @param  error: 错误
     *  @param  entity: 解析后的数据
     *  @param  jsonResponse: 未解析的数据
     */
    public typealias AuthHandler = ((_ error: Error?, _ entity: AuthEntity?, _ jsonResponse: [AnyHashable: Any]?) -> Void)
    private var authHandler: AuthHandler?
    
    private var _auth: TencentOAuth?
    
    // 在调用前必须注册
    public func register(appKey: String) {
        _auth = TencentOAuth(appId: appKey, andDelegate: self)
    }
    
    public func isInstalled() -> Bool {
        return QQApiInterface.isQQInstalled() && QQApiInterface.isQQSupportApi()
    }
    
    public func handleOpen(url: URL) -> Bool {
        if TencentOAuth.handleOpen(url) {
            return true
        } else {
            return QQApiInterface.handleOpen(url, delegate: self)
        }
    }
    
    public func isQQInstalled() -> Bool {
        return QQApiInterface.isQQInstalled()
    }
    
    public func isQZoneSupported() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "mqqopensdkapiV3://")!)
    }
    
}

/// MARK: 认证
public extension XQQ {
    
    public func auth(with handler: AuthHandler? = nil) {
        self.authHandler = handler
        _auth?.authorize([kOPEN_PERMISSION_GET_SIMPLE_USER_INFO])
    }
    
    private func _handle(error: Error?, response: APIResponse?) {
        if let jsonResponse = response?.jsonResponse {
            let entity = try? JSONDecoder.decode(AuthEntity.self, from: jsonResponse)
            authHandler?(nil, entity, jsonResponse)
        } else {
            authHandler?(error, nil, nil)
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
            case headImgUrl = "figureurl_qq_2"
            case gender
            case province
            case city
            case country
            case unionid
        }
        
        enum Gender: String {
            case unknown = "未知"
            case male = "男"
            case female = "女"
            
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
            let genderString = try container.decodeIfPresent(String.self, forKey: .gender)
            gender = Gender(rawValue: genderString ?? "未知") ?? .unknown
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

extension XQQ: TencentSessionDelegate {
    
    public func tencentDidLogin() {
        if _auth?.getUserInfo() == true {
            #if DEBUG
            NSLog("com.SwiftX.OpenSDK.XQQ   --   login success")
            #endif
        } else {
            _handle(error: NSError(domain: "com.SwiftX.OpenSDK.QQ", code: -1, description: "QQ登录失败"), response: nil)
        }
    }
    
    public func tencentDidNotLogin(_ cancelled: Bool) {
        _handle(error: NSError(domain: "com.SwiftX.OpenSDK.QQ", code: -1, description: "QQ登录失败"), response: nil)
    }
    
    public func tencentDidNotNetWork() {
        _handle(error: NSError(domain: "com.SwiftX.OpenSDK.QQ", code: -1, description: "网络连接错误"), response: nil)
    }
    
    public func getUserInfoResponse(_ response: APIResponse!) {
        _handle(error: nil, response: response)
    }
    
}

extension XQQ: QQApiInterfaceDelegate {
    
    public func onReq(_ req: QQBaseReq!) {
        
    }
    
    public func onResp(_ resp: QQBaseResp!) {
        
    }
    
    public func isOnlineResponse(_ response: [AnyHashable : Any]!) {
        
    }
    
}
