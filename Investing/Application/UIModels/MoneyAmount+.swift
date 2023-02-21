//
//  MoneyAmount+.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import Foundation
import InvestModels

public extension MoneyAmount {
    init(uiCurrency: UICurrency, value: Double) {
        self.init(
            currency: .init(rawValue: uiCurrency.rawValue.lowercased()) ?? .usd,
            value: value
        )
    }
}
