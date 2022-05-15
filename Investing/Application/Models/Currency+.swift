//
//  Currency+.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import Foundation
import InvestModels

extension Currency {
    static func new(currency: Price.Currency) -> Currency? {
        Currency(rawValue: currency.rawValue.uppercased())
    }
}
