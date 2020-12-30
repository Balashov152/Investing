//
//  Settings.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Foundation

struct Settings {
    static let shared = Settings()

    var apiToken: String {
        get { Storage.token ?? "t.ElO9J6o7HNsTSVH5LG6tRrMqG3bAKQFG3YehULcdPaYzhK0CXcyMVy4rhtbNUuOHwXo8VAs-QUgA-KbHNLg5yg" }
        set { Storage.token = newValue }
    }
}
