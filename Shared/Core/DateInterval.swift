//
//  DateInterval.swift
//  Investing
//
//  Created by Sergey Balashov on 12.02.2021.
//

import Foundation

struct DateInterval: Hashable, Codable {
    static let lastYear = DateInterval(start: DateFormatter.format("yyyy").date(from: "2018")!.startOfYear,
                                       end: Date().endOfYear)

    let start, end: Date
}
