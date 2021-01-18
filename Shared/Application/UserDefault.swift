//
//  UserDefault.swift
//  Investing
//
//  Created by Sergey Balashov on 17.01.2021.
//

import Foundation

extension UserDefault {
    enum ClearKeys: String {
        case token, currency
        case startInterval, endInterval
        case payInAvg
    }

    enum StorageKeys: String {
        case currentDBVersion
    }
}

@propertyWrapper
struct UserDefault<Value> {
    private let key: String
    private let defaultValue: Value

    init(key: StorageKeys, defaultValue: Value) {
        self.key = key.rawValue
        self.defaultValue = defaultValue
    }

    init(key: ClearKeys, defaultValue: Value) {
        self.key = key.rawValue
        self.defaultValue = defaultValue
    }

    var wrappedValue: Value {
        get {
            // Read value from UserDefaults
            UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            // Set value to UserDefaults
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
