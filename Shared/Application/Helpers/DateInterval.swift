//
//  DateInterval.swift
//  Investing
//
//  Created by Sergey Balashov on 12.02.2021.
//

import Foundation

struct DateInterval: Hashable, Codable {
    static let lastYear = DateInterval(
        start: DateFormatter.format("yyyy").date(from: "2018")!.startOfYear,
        end: Date().endOfYear
    )

    static let yearAgo = DateInterval(
        start: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
        end: Date()
    )

    let start, end: Date

    var range: ClosedRange<Date> { start ... end }
}

extension Calendar {
    func dates(from: Date, to end: Date, by component: Calendar.Component = .day, in format: String) -> [String] {
        var startDate = from
        var dates: [String] = []

        while startDate <= end {
            dates.append(startDate.string(format: format))

            startDate = date(byAdding: component, value: 1, to: startDate)!
        }
        return dates
    }
}
