//
//  Currency.swift
//  Investing
//
//  Created by Sergey Balashov on 10.12.2020.
//

import Foundation

public enum Currency: String, Codable, CaseIterable, Comparable {
    case RUB, USD, EUR, GBP, HKD, CHF, JPY, CNY, TRY
    
    public static func < (lhs: Currency, rhs: Currency) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
