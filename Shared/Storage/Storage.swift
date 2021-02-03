//
//  Storage.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Combine
import Foundation

enum Storage {
    static var isAuthorized: Bool {
        debugPrint("token", token)
        return !token.isEmpty
    }

    @UserDefault(key: .token, defaultValue: "")
    static var token: String

    @UserDefault(key: .currentDBVersion, defaultValue: 0)
    static var currentDBVersion: Int
}
