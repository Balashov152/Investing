//
//  Currency+Ex.swift
//  Investing
//
//  Created by Sergey Balashov on 20.02.2021.
//

import Foundation
import InvestModels

extension Currency {
    var locale: Locale {
        switch self {
        case .USD:
            return Locale(identifier: "en_US")
        case .RUB:
            return Locale(identifier: "ru_RU")
        case .EUR:
            return Locale(identifier: "eu_EU")
        default:
            return Locale(identifier: "ru_RU")
        }
    }

    var symbol: String {
        locale.currencySymbol ?? rawValue
    }
}
