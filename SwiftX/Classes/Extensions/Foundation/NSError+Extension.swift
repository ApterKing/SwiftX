//
//  NSError+Extension.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/23.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

public extension NSError {
    
    convenience init(domain: String, code: Int, description: String? = nil) {
        if let string = description {
            let info = [NSLocalizedDescriptionKey: string]
            self.init(domain: domain, code: code, userInfo: info)
        } else {
            let description = String(format: NSLocalizedString("swift-x_error", comment: ""), code)
            let info = [NSLocalizedDescriptionKey: description]
            self.init(domain: domain, code: code, userInfo: info)
        }
    }
}
