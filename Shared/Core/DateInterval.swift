//
//  DateInterval.swift
//  Investing
//
//  Created by Sergey Balashov on 12.02.2021.
//

import Foundation

struct DateInterval: Hashable, Codable {
    static let lastYear = DateInterval(start: Calendar.current.date(byAdding: .year, value: -1, to: Date())!, end: Date())

    let start, end: Date
}
