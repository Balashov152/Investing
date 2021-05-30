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
        case .EUR:
            return Locale(identifier: "en_EU")
        case .RUB:
            return Locale(identifier: "ru_RU")
        default:
            return .current
        }
    }

    var symbol: String {
        locale.currencySymbol ?? rawValue
    }
}
