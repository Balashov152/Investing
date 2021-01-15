//
//  OperationSum.swift
//  Investing
//
//  Created by Sergey Balashov on 21.12.2020.
//

import Foundation
import InvestModels

extension Collection where Element == Operation {
    var sum: Double {
        map { $0.payment }.reduce(0, +)
    }

    func envSum(env: Environment) -> Double {
        map { operation in
            operation.convertPayment(to: env.operationCurrency())
        }.map { $0.value }.reduce(0, +)
    }
}

extension Collection where Element == MoneyAmount {
    var sum: Double {
        map { $0.value }.reduce(0, +)
    }
}

extension Collection where Element == Double {
    var sum: Double {
        reduce(0, +)
    }
}

extension DateFormatter {
    static func format(_ string: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = string
        return formatter
    }
}

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
//        if doubleValue < 5 {
//            formater.maximumFractionDigits = 4
//        }
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
