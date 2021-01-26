//
//  FormattedCurrency.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Foundation
import InvestModels

extension Double {
    func formattedCurrency(locale: Locale = Locale(identifier: "ru_RU")) -> String {
        (self as NSNumber).formattedCurrency(locale: locale)
    }
}

extension NSNumber {
    func formattedCurrency(locale: Locale = Locale(identifier: "ru_RU")) -> String {
        let formater = NumberFormatter()
        formater.groupingSeparator = " "
        formater.numberStyle = .currency
        formater.locale = locale
        let isInteger = floor(doubleValue) == doubleValue
        formater.minimumFractionDigits = isInteger ? 0 : 2

        if abs(doubleValue).isLess(than: 1) {
            formater.maximumFractionDigits = 4
        }
        return formater.string(from: self).orEmpty
    }
}

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
}
