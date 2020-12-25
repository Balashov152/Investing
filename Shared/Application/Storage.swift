//
//  Storage.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Foundation

struct Storage {
    enum Keys: String {
        case token, instruments, usdValue
        case currentDBVersion
    }

    static var isAuthorized: Bool { token != nil }

    static var token: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.token.rawValue)
        } set {
            UserDefaults.standard.set(newValue, forKey: Keys.token.rawValue)
        }
    }

    static var instruments: Data? {
        get {
            UserDefaults.standard.data(forKey: Keys.instruments.rawValue)
        } set {
            UserDefaults.standard.set(newValue, forKey: Keys.instruments.rawValue)
        }
    }

    static var currentDBVersion: Int {
        get {
            UserDefaults.standard.integer(forKey: Keys.currentDBVersion.rawValue)
        } set {
            UserDefaults.standard.set(newValue, forKey: Keys.currentDBVersion.rawValue)
        }
    }
}
