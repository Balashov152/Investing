//
//  Storage.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Combine
import Foundation

enum Storage {
    static var isAuthorized: Bool { !token.isEmpty }

    static func clear() {
        Storage.token = ""

        UserDefault<String>.ClearKeys.allCases.forEach {
            UserDefaults.standard.removeObject(forKey: $0.rawValue)
        }
    }

    @UserDefault(key: .token, defaultValue: "")
    static var token: String

    @UserDefault(key: .currentDBVersion, defaultValue: 0)
    static var currentDBVersion: Int
}
