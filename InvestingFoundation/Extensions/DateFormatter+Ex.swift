//
//  DateFormatter+Ex.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Foundation

public extension DateFormatter {
    static func format(_ string: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = string
        return formatter
    }
}

public extension Date {
    static func from(string: String, format: String) -> Date? {
        DateFormatter.format(format).date(from: string)
    }
}
