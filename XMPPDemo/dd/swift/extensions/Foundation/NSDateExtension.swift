//
//  NSDateExtension.swift
//  Dong
//
//  Created by darkdong on 15/2/28.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import Foundation

extension NSDate {
    var secondsSince1970: Int {
        return Int(self.timeIntervalSince1970)
    }
    
    var secondsString: String {
        return "\(self.secondsSince1970)"
    }
    
    var millisecondsSince1970: Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    var millisecondsString: String {
        return "\(self.millisecondsSince1970)"
    }
    
    class var secondsElapsedSinceToday: Int {
        let flags: NSCalendarUnit = [.NSHourCalendarUnit, .NSMinuteCalendarUnit, .NSSecondCalendarUnit]
        let components = NSCalendar.currentCalendar().components(flags, fromDate: NSDate())
        let seconds = components.hour * 3600 + components.minute * 60 + components.second
        return seconds
    }
    
    class var theDayBeforeYesterday: NSDate? {
        return NSDate().dateByAddingCalendarDays(-2)
    }
    
    class var yesterday: NSDate? {
        return NSDate().dateByAddingCalendarDays(-1)
    }

    class var tomorrow: NSDate? {
        return NSDate().dateByAddingCalendarDays(1)
    }
    
    func dateByAddingCalendarDays(days: Int) -> NSDate? {
        let components = NSDateComponents()
        components.day = days
        return NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: self, options: NSCalendarOptions(rawValue: 0))
    }
    
    enum Difference {
        case Now
        case Today
        case Yesterday
        case TheDayBeforeYesterday
        case Seconds(Int)
        case Minutes(Int)
        case Hours(Int)
        case Days(Int)
        case Weeks(Int)
        case Months(Int)
        case Years(Int)
        case Unknown
        
        func print() {
            switch self {
            case .Now:
                DDLog2.print("Now")
            case .Today:
                DDLog2.print("Today")
            case .Yesterday:
                DDLog2.print("Yesterday")
            case .TheDayBeforeYesterday:
                DDLog2.print("TheDayBeforeYesterday")
            case .Unknown:
                DDLog2.print("Unknown")
            case .Seconds(let seconds):
                DDLog2.print("\(seconds) seconds before")
            case .Minutes(let minutes):
                DDLog2.print("\(minutes) minutes before")
            case .Hours(let hours):
                DDLog2.print("\(hours) hours before")
            case .Days(let days):
                DDLog2.print("\(days) days before")
            case .Weeks(let weeks):
                DDLog2.print("\(weeks) weeks before")
            case .Months(let months):
                DDLog2.print("\(months) months before")
            case .Years(let years):
                DDLog2.print("\(years) years before")
            }
        }
    }
    
    struct DifferenceOptions: OptionSetType {
        private var value: UInt = 0
        
        var rawValue: UInt { return self.value }
        
        init(rawValue value: UInt) { self.value = value }
        init(nilLiteral: ()) { self.value = 0 }
        
        static var allZeros: DifferenceOptions { return self.init(rawValue: 0) }

        static var Now: DifferenceOptions { return self.init(rawValue: 0b0001) }
        static var Today: DifferenceOptions { return self.init(rawValue: 0b0010) }
        static var Yesterday: DifferenceOptions { return self.init(rawValue: 0b0100) }
        static var TheDayBeforeYesterday: DifferenceOptions { return self.init(rawValue: 0b1000) }

        static var Seconds: DifferenceOptions   { return self.init(rawValue: 0b0001_0000) }
        static var Minutes: DifferenceOptions   { return self.init(rawValue: 0b0010_0000) }
        static var Hours: DifferenceOptions   { return self.init(rawValue: 0b0100_0000) }
        static var Days: DifferenceOptions   { return self.init(rawValue: 0b1000_0000) }
        
        static var Weeks: DifferenceOptions   { return self.init(rawValue: 0b0001_0000_0000) }
        static var Months: DifferenceOptions   { return self.init(rawValue: 0b0010_0000_0000) }
        static var Years: DifferenceOptions   { return self.init(rawValue: 0b0100_0000_0000) }
        
        static var All: DifferenceOptions { return self.init(rawValue: UInt.max) }
    }
    
    
    func differenceFromNow(options: DifferenceOptions = .All) -> Difference {
        let difference = Int(NSDate().timeIntervalSince1970 - self.timeIntervalSince1970)
        
        //now
        if options.intersect(DifferenceOptions.Now) != [] {
            let seconds = difference
            if seconds < 10 {
                return .Now
            }
        }
        
        //seconds
        if options.intersect(DifferenceOptions.Seconds) != [] {
            let seconds = difference
            if seconds < 60 {
                return .Seconds(seconds)
            }
        }
        
        //minutes
        if options.intersect(DifferenceOptions.Minutes) != [] {
            let minutes = difference / 60
            if (minutes < 60) {
                return .Minutes(minutes)
            }
        }
        
        //hours
        if options.intersect(DifferenceOptions.Hours) != [] {
            let hours = difference / (60 * 60)
            if (hours < 24) {
                return .Hours(hours)
            }
        }
        
        //today
        if options.intersect(DifferenceOptions.Today) != [] {
            if self.isDayToday() {
                return .Today
            }
        }
        
        //yesterday
        if options.intersect(DifferenceOptions.Yesterday) != [] {
            if self.isDayYesterday() {
                return .Yesterday
            }
        }
        
        //the day before yesterday
        if options.intersect(DifferenceOptions.TheDayBeforeYesterday) != [] {
            if self.isDayTheDayBeforeYesterday() {
                return .TheDayBeforeYesterday
            }
        }

        //days
        if options.intersect(DifferenceOptions.Days) != [] {
            let secondsPerDay = 60 * 60 * 24
            let days = (difference - NSDate.secondsElapsedSinceToday) / secondsPerDay + 1
            if days < 31 {
                return .Days(days)
            }
        }
        
        //months
        if options.intersect(DifferenceOptions.Months) != [] {
            var months = difference / (60 * 60 * 24 * 30)
            if (months < 12) {
                if months == 0 {
                    months = 1
                }
                return .Months(months)
            }
        }
        
        //years
        if options.intersect(DifferenceOptions.Years) != [] {
            var years = difference / (60 * 60 * 24 * 365)
            if years == 0 {
                years = 1
            }
            return .Years(years)
        }
        
        return .Unknown
    }
    
    func dateComponentsDifferenceFromDate(date: NSDate!) -> NSDateComponents {
        let calendar = NSCalendar.currentCalendar()
        let flags: NSCalendarUnit = [.NSYearCalendarUnit, .NSMonthCalendarUnit, .NSDayCalendarUnit]
        let com1 = calendar.components(flags, fromDate: self)
        let com2 = calendar.components(flags, fromDate: date)
        let difference = NSDateComponents()
        difference.year = com1.year - com2.year
        difference.month = com1.month - com2.month
        difference.day = com1.day - com2.day
        return difference
    }
    
    func hasSameYMD(date: NSDate!) -> Bool {
        let difference = self.dateComponentsDifferenceFromDate(date)
        return difference.year == 0 && difference.month == 0 && difference.day == 0
    }
    
    func isDayToday() -> Bool {
        return self.hasSameYMD(NSDate())
    }
    
    func isDayYesterday() -> Bool {
        return self.hasSameYMD(NSDate.yesterday)
    }
    
    func isDayTheDayBeforeYesterday() -> Bool {
        return self.hasSameYMD(NSDate.theDayBeforeYesterday)
    }
    
    func distanceToDate(date: NSDate!) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        var seconds = Int(date.timeIntervalSince1970 - self.timeIntervalSince1970)
        let secondsPerDay = 60 * 60 * 24
        let days = seconds / secondsPerDay
        seconds -= days * secondsPerDay
        
        let secondsPerHour = 60 * 60
        let hours = seconds / secondsPerHour
        seconds -= hours * secondsPerHour
        
        let secondsPerMinute = 60
        let minutes = seconds / secondsPerMinute
        seconds -= minutes * secondsPerMinute
        
        return (days, hours, minutes, seconds)
    }
}