//
//  UICurrency.swift
//  Investing
//
//  Created by Sergey Balashov on 28.02.2022.
//

import InvestModels

public enum UICurrency: String, Hashable, Comparable {
    case usd, rub, eur, cad, ils, chf, gbp

    init?(currency: Price.Currency) {
        self.init(rawValue: currency.rawValue.lowercased())
    }

    init?(currency: Currency) {
        self.init(rawValue: currency.rawValue.lowercased())
    }
    
    public static func < (lhs: UICurrency, rhs: UICurrency) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
