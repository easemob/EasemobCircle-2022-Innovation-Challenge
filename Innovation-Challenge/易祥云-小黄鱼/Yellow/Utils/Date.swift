//
//  Date.swift
//  Yellow
//
//  Created by Icey.Liao on 2022/11/29.
//

import Foundation

extension Date {

    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
    func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
    func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }

    func isInSameDay(as date: Date) -> Bool { Calendar.current.isDate(self, inSameDayAs: date) }

    var isInThisYear:  Bool { isInSameYear(as: Date()) }
    var isInThisMonth: Bool { isInSameMonth(as: Date()) }
    var isInThisWeek:  Bool { isInSameWeek(as: Date()) }

    var isInYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isInToday:     Bool { Calendar.current.isDateInToday(self) }
    var isInTomorrow:  Bool { Calendar.current.isDateInTomorrow(self) }

    var isInTheFuture: Bool { self > Date() }
    var isInThePast:   Bool { self < Date() }
}

extension Date {
    
    var formatedStringForMessageCell: String {
        
        // 先看一下是不是 同一天
        if isInToday {
            let df = DateFormatter()
            df.dateFormat = "HH:mm"
            return df.string(from: self)
        }
        
        if isInYesterday {
            let df = DateFormatter()
            df.dateFormat = "昨天 HH:mm"
            return df.string(from: self)
        }
        
        if isInThisWeek {
            let df = DateFormatter()
            df.dateFormat = "EEEE HH:mm"
            return df.string(from: self)
        }
        
        if isInThisYear {
            let df = DateFormatter()
            df.dateFormat = "MM月-dd日 HH:mm"
            return df.string(from: self)
        }
        
        let df = DateFormatter()
        df.dateFormat = "yyyy年-MM月-dd日 HH:mm"
        return df.string(from: self)
    }
}
