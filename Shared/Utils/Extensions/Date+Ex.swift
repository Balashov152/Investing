//
//  Date+Ex.swift
//  Investing
//
//  Created by Sergey Balashov on 14.01.2021.
//

import Foundation

extension Date {
    func string(format: String) -> String {
        DateFormatter.format(format).string(from: self)
    }

    var month: Int {
        Calendar.current.component(.month, from: self)
    }

    var year: Int {
        Calendar.current.component(.year, from: self)
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    var startOfYear: Date {
        Calendar.current.startOfYear(self)
    }

    var endOfYear: Date {
        Calendar.current.endOfYear(self).endOfDay
    }

    func years(value: Int) -> Date {
        Calendar.current.date(byAdding: .year, value: value, to: self) ?? self
    }

    func days(value: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: value, to: self) ?? self
    }
}

extension Calendar {
    func startOfYear(_ date: Date) -> Date {
        self.date(from: dateComponents([.year], from: date)) ?? Date()
    }

    func endOfYear(_ date: Date) -> Date {
        self.date(from: DateComponents(year: component(.year, from: date), month: 12, day: 31)) ?? Date()
    }
}
