//
//  UserDefaultWrapper.swift
//  Investing
//
//  Created by Sergey Balashov on 17.01.2021.
//

import Foundation

extension UserDefault {
    enum ClearKeys: String {
        case token, currency
        case dateInterval
        case payInAvg, expandedHome
        case adjustedAverage
        case averageCurrency
    }

    enum StorageKeys: String {
        case currentDBVersion
    }
}

@propertyWrapper
struct UserDefault<Value: Codable> {
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
            guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
                // Return defaultValue when no data in UserDefaults
                return defaultValue
            }

            // Convert data to the desire data type
            let value = try? JSONDecoder().decode(Value.self, from: data)
            return value ?? defaultValue
        }
        set {
            // Convert newValue to data
            let data = try? JSONEncoder().encode(newValue)

            // Set value to UserDefaults
            storage.set(data, forKey: key)
        }
    }
}

private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}
