//
//  UIResponder+Extension.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/27.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

private weak var g_currentFirstResponder: UIResponder?

extension UIResponder {
    
    class func currentFirstResponder() -> UIResponder? {
        g_currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(findFirstResponder(sender:)), to: nil, from: nil, for: nil)
        return g_currentFirstResponder
    }
    
    @objc func findFirstResponder(sender: AnyObject?) {
        g_currentFirstResponder = self
    }
}
