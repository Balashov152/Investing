//
//  OperationSum.swift
//  Investing
//
//  Created by Sergey Balashov on 21.12.2020.
//

import Foundation
import InvestModels

extension Collection where Element == Operation {
    func filter(type: Operation.OperationTypeWithCommission) -> [Element] {
        filter { $0.operationType == type }
    }

    func filter(types: Set<Operation.OperationTypeWithCommission>) -> [Element] {
        filter { types.contains($0.operationType) }
    }

    func filter(types: Set<Operation.OperationTypeWithCommission>,
                or condition: (Operation) -> (Bool)) -> [Element]
    {
        filter { types.contains($0.operationType) || condition($0) }
    }

    /// sum payment
    var sum: Double {
        map { $0.payment }.reduce(0, +)
    }

    func currencySum(to currency: Currency) -> MoneyAmount {
        let value = map { operation in
            operation.convertPayment(to: currency)
        }.map { $0.value }.reduce(0, +)

        return MoneyAmount(currency: currency, value: value)
    }
}

extension Collection where Element == MoneyAmount {
    var sum: Double {
        map { $0.value }.sum
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
