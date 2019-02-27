//
//  XWeChat.swift
//  SwiftX
//
//  Created by wangcong on 2019/2/27.
//  Copyright © 2019 wangcong. All rights reserved.
//

import UIKit

final public class XWeChat: NSObject {
    
    static let `default` = XWeChat()
    private lazy var auth: Auth = {
        let auth = Auth()
        return auth
    }()
    private lazy var pay: Pay = {
        let pay = Pay()
        return pay
    }()
    
    public override init() {
        
    }

}

// 登录
extension XWeChat  {
    
    class Auth: NSObject {
        
    }
    
}

// 支付
extension XWeChat {
    
    class Pay: NSObject {
        
    }
    
}

// 分享
extension XWeChat {
    
    class Share: NSObject {
        
    }
    
}
