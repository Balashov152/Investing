//
//  Storage.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Combine
import Foundation

public enum Storage {
    public static var isAuthorized: Bool { !token.isEmpty }

    public static func clear() {
        Storage.token = ""

        UserDefault<String>.ClearKeys.allCases.forEach {
            UserDefaults.standard.removeObject(forKey: $0.rawValue)
        }
    }

    @UserDefault(key: .token, defaultValue: "")
    public static var token: String

    @UserDefault(key: .newToken, defaultValue: "")
    public static var newToken: String

    @UserDefault(key: .currentDBVersion, defaultValue: 0)
    public static var currentDBVersion: Int
}
