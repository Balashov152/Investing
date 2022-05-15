//
//  MoneyAmount+.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import Foundation
import InvestModels

public extension MoneyAmount {
    init(currency: Price.Currency, value: Double) {
        self.init(
            currency: InvestModels.Currency(rawValue: currency.rawValue.uppercased()) ?? .USD,
            value: value
        )
    }

    init(uiCurrency: UICurrency, value: Double) {
        self.init(
            currency: InvestModels.Currency(rawValue: uiCurrency.rawValue.uppercased()) ?? .USD,
            value: value
        )
    }
}
