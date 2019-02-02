//
//  Calendar+Extension.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/12.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

public extension Calendar {
    
    public var shortChineseWeekdaySymbols: [String] {
        return ["日", "一", "二", "三", "四", "五", "六"]
    }
    
    public var chineseWeekdaySymbols: [String] {
        return ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
    }
    
    public var shortStandloneChineseWeekdaySymbols: [String] {
        return ["一", "二", "三", "四", "五", "六", "日"]
    }
    
    public var standloneChineseWeekdaySymbols: [String] {
        return ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
    }
    
}

public extension Calendar {
    
    /// let date = Date() // "Jan 12, 2017, 7:07 PM"
    /// Calendar.current.numberOfDaysInMonth(for: date) -> 31
    public func numberOfDaysInMonth(for date: Date) -> Int {
        return range(of: .day, in: .month, for: date)!.count
    }

}
