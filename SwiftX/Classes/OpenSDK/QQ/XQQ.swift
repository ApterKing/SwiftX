//
//  XQQ.swift
//  SwiftX
//
//  Created by wangcong on 2019/2/27.
//  Copyright © 2019 wangcong. All rights reserved.
//

import UIKit

final public class XQQ: NSObject {
    
    static let `default` = XQQ()
    private lazy var auth: Auth = {
        let auth = Auth()
        return auth
    }()

    public override init() {
        
    }
    
}

// 登录
public extension XQQ {
    
    public class Auth: NSObject {
        
    }
    
}

