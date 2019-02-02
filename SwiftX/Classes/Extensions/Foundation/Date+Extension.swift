//
//  Date+Extension.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/12.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

// MARK: Format
public extension Date {
    
    public init?(from date: String, format: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        guard let date = formatter.date(from: date) else {
            return nil
        }
        self.init(timeInterval:0, since: date)
    }
    
    public func format(to format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
}

/// MARK: pretty
public extension Date {
    
    public func prettyDisplayedString() -> String {
        let now = Date()
        let interval = now.timeIntervalSince(self)
        switch interval {
        case 0..<60:
            return "刚刚"
        case 60..<3600:
            return String(format: "%.0f分钟前", interval / 60)
        case 3600..<86400:
            return String(format: "%.0f小时前", interval / 3600)
        default:
            if now.year == self.year {
                return self.format(to: "MM-dd HH:mm")
            } else {
                return self.format(to: "yyyy-MM-dd HH:mm")
            }
        }
    }
}

/// MARK: Calendar
public extension Date {

    public var calendar: Calendar {
        return Calendar.current
    }
    
    public var timestamp: TimeInterval {
        return self.timeIntervalSince1970
    }
    
    public var weekOfYear: Int {
        return calendar.component(.weekOfYear, from: self)
    }
    
    public var weekOfMonth: Int {
        return calendar.component(.weekOfMonth, from: self)
    }
    
    public var year: Int {
        get {
            return calendar.component(.year, from: self)
        }
        set {
            guard newValue > 0 else { return }
            let currentYear = calendar.component(.year, from: self)
            let yearsToAdd = newValue - currentYear
            self = adding(.year, value: yearsToAdd)
        }
    }
    
    public var month: Int {
        get {
            return calendar.component(.month, from: self)
        }
        set {
            let allowedRange = calendar.range(of: .month, in: .year, for: self)!
            guard allowedRange.contains(newValue) else { return }
            
            let currentMonth = calendar.component(.month, from: self)
            let monthsToAdd = newValue - currentMonth
            self = adding(.month, value: monthsToAdd)
        }
    }
    
    public var day: Int {
        get {
            return calendar.component(.day, from: self)
        }
        set {
            let allowedRange = calendar.range(of: .day, in: .month, for: self)!
            guard allowedRange.contains(newValue) else { return }
            
            let currentDay = calendar.component(.day, from: self)
            let daysToAdd = newValue - currentDay
            self = adding(.day, value: daysToAdd)
        }
    }
    
    //   1 ~ 7  周日 ~ 周六
    public var weekday: Int {
        return calendar.component(.weekday, from: self)
    }

    //  1 ~ 7  周一 ~ 周日
    public var chineseWeekday: Int {
        return (weekday + 6) % 7
    }
    
    public var hour: Int {
        get {
            return calendar.component(.hour, from: self)
        }
        set {
            let allowedRange = calendar.range(of: .hour, in: .day, for: self)!
            guard allowedRange.contains(newValue) else { return }
            
            let currentHour = calendar.component(.hour, from: self)
            let hoursToAdd = newValue - currentHour
            self = adding(.hour, value: hoursToAdd)
        }
    }
    
    public var minute: Int {
        get {
            return calendar.component(.minute, from: self)
        }
        set {
            let allowedRange = calendar.range(of: .minute, in: .hour, for: self)!
            guard allowedRange.contains(newValue) else { return }
            
            let currentMinutes = calendar.component(.minute, from: self)
            let minutesToAdd = newValue - currentMinutes
            self = adding(.minute, value: minutesToAdd)
        }
    }
    
    public var second: Int {
        get {
            return calendar.component(.second, from: self)
        }
        set {
            let allowedRange = calendar.range(of: .second, in: .minute, for: self)!
            guard allowedRange.contains(newValue) else { return }
            
            let currentSeconds = calendar.component(.second, from: self)
            let secondsToAdd = newValue - currentSeconds
            self = adding(.second, value: secondsToAdd)
        }
    }
    
    public var millisecond: Int {
        get {
            return calendar.component(.nanosecond, from: self) / 1000000
        }
        set {
            let nanoSeconds = newValue * 1000000
            let allowedRange = calendar.range(of: .nanosecond, in: .second, for: self)!
            guard allowedRange.contains(nanoSeconds) else { return }
            self = adding(.nanosecond, value: nanoSeconds)
        }
    }
    
    public var nanosecond: Int {
        get {
            return calendar.component(.nanosecond, from: self)
        }
        set {
            let allowedRange = calendar.range(of: .nanosecond, in: .second, for: self)!
            guard allowedRange.contains(newValue) else { return }
            
            let currentNanoseconds = calendar.component(.nanosecond, from: self)
            let nanosecondsToAdd = newValue - currentNanoseconds
            self = adding(.nanosecond, value: nanosecondsToAdd)
        }
    }
    
    public func adding(_ component: Calendar.Component, value: Int) -> Date {
        return calendar.date(byAdding: component, value: value, to: self)!
    }
}
