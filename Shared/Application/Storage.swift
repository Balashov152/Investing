//
//  Storage.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Combine
import Foundation

extension Storage {
    enum Keys: String {
        case token, currency
        case currentDBVersion
        case startInterval, endInterval
    }
}

enum Storage {
    static var isAuthorized: Bool { token != nil }

    @UserDefault(key: .currency, defaultValue: nil)
    static var currency: String?

    @UserDefault(key: .token, defaultValue: nil)
    static var token: String?

    @UserDefault(key: .currentDBVersion, defaultValue: 0)
    static var currentDBVersion: Int

    static var dateInterval: DateInterval? {
        get {
            guard let start = startDateInterval, let end = endDateInterval
            else { return nil }
            return DateInterval(start: start, end: end)
        } set {
            startDateInterval = newValue?.start
            endDateInterval = newValue?.end
        }
    }

    @UserDefault(key: .startInterval, defaultValue: nil)
    private static var startDateInterval: Date?

    @UserDefault(key: .endInterval, defaultValue: nil)
    private static var endDateInterval: Date?
}
