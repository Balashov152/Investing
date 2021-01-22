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
        case payInAvg, expanded
    }

    enum StorageKeys: String {
        case currentDBVersion
    }
}

@propertyWrapper
struct UserDefault<Value> {
    private let key: String
    private let defaultValue: Value

    private var storage: UserDefaults = .standard

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
            storage.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            // Set value to UserDefaults
            if let optional = newValue as? AnyOptional, optional.isNil {
                storage.removeObject(forKey: key)
            } else {
                storage.setValue(newValue, forKey: key)
            }
        }
    }
}

private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}
