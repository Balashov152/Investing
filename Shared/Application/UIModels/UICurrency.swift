//
//  UICurrency.swift
//  Investing
//
//  Created by Sergey Balashov on 28.02.2022.
//

import InvestModels

enum UICurrency: String, Equatable, Comparable {
    static func < (lhs: UICurrency, rhs: UICurrency) -> Bool {
        lhs.hashValue < rhs.hashValue
    }

    case usd, rub, eur, cad, ils, chf, gbp

    init?(currency: Price.Currency) {
        self.init(rawValue: currency.rawValue.lowercased())
    }

    init?(currency: Currency) {
        self.init(rawValue: currency.rawValue.lowercased())
    }
}
