//
//  Settings.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Foundation
import InvestModels

struct Settings {
    static var shared = Settings()

    var currency: Currency? {
        get { Currency(rawValue: Storage.currency.orEmpty) }
        set { Storage.currency = newValue?.rawValue }
    }

    var apiToken: String {
        get { Storage.token ?? "t.ElO9J6o7HNsTSVH5LG6tRrMqG3bAKQFG3YehULcdPaYzhK0CXcyMVy4rhtbNUuOHwXo8VAs-QUgA-KbHNLg5yg" }
        set { Storage.token = newValue }
    }

    var dateInterval: DateInterval {
        get { Storage.dateInterval ?? DateInterval.lastYear }
        set { Storage.dateInterval = newValue }
    }
}
