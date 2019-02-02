//
//  UIFont+Extension.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/28.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

public extension UIFont {
    
    static func pingFangSCRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "PingFang-SC-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func pingFangSCMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "PingFang-SC-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func pingFangSCLight(size: CGFloat) -> UIFont {
        return UIFont(name: "PingFang-SC-Light", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
}
