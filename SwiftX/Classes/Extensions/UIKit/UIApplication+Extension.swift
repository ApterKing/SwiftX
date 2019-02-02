//
//  UIApplication+Extension.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/27.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

public extension UIApplication {
    
    static var memoryUsage: Float? {
        get {
            var info = mach_task_basic_info()
            var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info) / MemoryLayout<integer_t>.size)
            let kerr = withUnsafeMutablePointer(to: &info) { infoPtr in
                return infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { (machPtr: UnsafeMutablePointer<integer_t>) in
                    return task_info(
                        mach_task_self_,
                        task_flavor_t(MACH_TASK_BASIC_INFO),
                        machPtr,
                        &count
                    )
                }
            }
            guard kerr == KERN_SUCCESS else {
                return nil
            }
            return Float(info.resident_size) / (1024 * 1024)
        }
    }
}
