//
//  UIColor+Extension.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/12.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

// MARK: 通过16进制初始化UIColor
public extension UIColor {
    
    public var hexString: String {
        get {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            self.getRed(&red, green: &green, blue: &blue, alpha: nil)
            
            let r = Int(255.0 * red)
            let g = Int(255.0 * green)
            let b = Int(255.0 * blue)
            
            let string = String(format: "#%02x%02x%02x", r, g, b)
            return string
        }
    }
    
    public convenience init(numberColor: Int, alpha: CGFloat = 1.0) {
        self.init(hexColor: String(numberColor, radix: 16), alpha: alpha)
    }
    
    public convenience init(hexColor: String, alpha: CGFloat = 1.0) {
        var hex = hexColor.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if hex.hasPrefix("#") {
            hex.remove(at: hex.startIndex)
        }
        if hex.hasPrefix("0x") || hex.hasPrefix(("0X")) {
            hex.removeSubrange((hex.startIndex ..< hex.index(hex.startIndex, offsetBy: 2)))
        }
        
        guard let hexNum = Int(hex, radix: 16) else {
            self.init(red: 0, green: 0, blue: 0, alpha: 0)
            return
        }
        switch hex.count {
        case 3:
            self.init(red: CGFloat(((hexNum & 0xF00) >> 8).duplicate4bits) / 255.0,
                      green: CGFloat(((hexNum & 0x0F0) >> 4).duplicate4bits) / 255.0,
                      blue: CGFloat((hexNum & 0x00F).duplicate4bits) / 255.0,
                      alpha: alpha)
        case 6:
            self.init(red: CGFloat((hexNum & 0xFF0000) >> 16) / 255.0,
                      green: CGFloat((hexNum & 0x00FF00) >> 8) / 255.0,
                      blue: CGFloat((hexNum & 0x0000FF) >> 0) / 255.0,
                      alpha: alpha)
        default:
            self.init(red: 0, green: 0, blue: 0, alpha: 0)
        }
    }
    
}

private extension Int {
    var duplicate4bits: Int {
        return self << 4 + self
    }
}

func ==(lhs: UIColor, rhs: UIColor) -> Bool {
    let tolerance: CGFloat = 0.01
    var r1: CGFloat = 0.0
    var g1: CGFloat = 0.0
    var b1: CGFloat = 0.0
    var a1: CGFloat = 0.0
    
    var r2: CGFloat = 0.0
    var g2: CGFloat = 0.0
    var b2: CGFloat = 0.0
    var a2: CGFloat = 0.0
    
    lhs.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
    rhs.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
    
    return fabs(r1-r2) <= tolerance && fabs(g1-g2) <= tolerance && fabs(b1-b2) <= tolerance && fabs(a1-a2) <= tolerance
}

func !=(lhs: UIColor, rhs: UIColor) -> Bool {
    return (lhs == rhs)
}
