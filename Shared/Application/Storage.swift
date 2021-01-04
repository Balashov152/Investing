//
//  Storage.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Combine
import Foundation

struct Storage {
    enum Keys: String {
        case token, instruments, usdValue
        case currentDBVersion
        case startInterval, endInterval
    }

    static var isAuthorized: Bool { token != nil }
    static var defaults: UserDefaults { .standard }

    static var token: String? {
        get {
            defaults.string(forKey: Keys.token.rawValue)
        } set {
            defaults.set(newValue, forKey: Keys.token.rawValue)
        }
    }

    static var dateInterval: DateInterval? {
        get {
            let formatter = DateFormatter.format("yyyy-MM-dd")

            guard let start = defaults.string(forKey: Keys.startInterval.rawValue),
                  let end = defaults.string(forKey: Keys.endInterval.rawValue),
                  let startDate = formatter.date(from: start),
                  let endDate = formatter.date(from: end)
            else {
                return nil
            }

            return DateInterval(start: startDate, end: endDate)

        } set {
            guard let interval = newValue else { return }
            let formatter = DateFormatter.format("yyyy-MM-dd")
            defaults.set(formatter.string(from: interval.start), forKey: Keys.startInterval.rawValue)
            defaults.set(formatter.string(from: interval.end), forKey: Keys.endInterval.rawValue)
        }
    }

    static var currentDBVersion: Int {
        get {
            defaults.integer(forKey: Keys.currentDBVersion.rawValue)
        } set {
            defaults.set(newValue, forKey: Keys.currentDBVersion.rawValue)
        }
    }
}
