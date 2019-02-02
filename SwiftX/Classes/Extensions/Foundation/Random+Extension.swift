//
//  Random+Extension.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/27.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

public extension Int {
    
    // 0...Int.max
    public static var random: Int {
        get {
            return Int.random(max: Int.max)
        }
    }
    
    // 0...max
    public static func random(max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max)))
    }
    
    // min...max
    public static func random(lower min: Int, upper max: Int) -> Int {
        return Int.random(max: max - min + 1) + min
    }
}

public extension Double {
    
    // 0.0...1.0
    public static var random:Double {
        get {
            return Double(arc4random()) / 0xFFFFFFFF
        }
    }
    
    // min...max
    public static func random(lower min: Double, upper max: Double) -> Double {
        return Double.random * (max - min) + min
    }
}

public extension Float {
    
    // 0.0...1.0
    public static var random:Float {
        get {
            return Float(arc4random()) / 0xFFFFFFFF
        }
    }
    
    // min...max
    public static func random(lower min: Float, upper max: Float) -> Float {
        return Float.random * (max - min) + min
    }
}

public extension CGFloat {
    
    // -1.0...1.0
    public static var randomSign:CGFloat {
        get {
            return (arc4random_uniform(2) == 0) ? 1.0 : -1.0
        }
    }
    
    // 0.0...1.0
    public static var random:CGFloat {
        get {
            return CGFloat(Float.random)
        }
    }
    
    // min...max
    public static func random(lower min: CGFloat, upper max: CGFloat) -> CGFloat {
        return CGFloat.random * (max - min) + min
    }
}

