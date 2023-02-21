//
//  Currency+Ex.swift
//  Investing
//
//  Created by Sergey Balashov on 20.02.2021.
//

import Foundation
import InvestModels

extension Price.Currency {
    var locale: Locale {
        switch self {
        case .usd:
            return Locale(identifier: "en_US")
        case .eur:
            return Locale(identifier: "en_EU")
        case .rub:
            return Locale(identifier: "ru_RU")
        default:
            return .current
        }
    }

    var symbol: String {
        locale.currencySymbol ?? rawValue
    }
}
