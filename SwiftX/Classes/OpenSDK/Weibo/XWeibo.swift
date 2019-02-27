//
//  XWeibo.swift
//  SwiftX
//
//  Created by wangcong on 2019/2/27.
//  Copyright © 2019 wangcong. All rights reserved.
//

import UIKit

final public class XWeibo: NSObject {
    
    static let `default` = XWeibo()
    private lazy var auth: Auth = {
        let auth = Auth()
        return auth
    }()
    
    public override init() {
        
    }
    
}

// 登录
public extension XWeibo {
    
    public class Auth: NSObject {
        
    }
    
}

