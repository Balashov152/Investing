//
//  FormattedCurrency.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Foundation
import InvestModels

extension Double {
    func formattedCurrency(locale: Locale = .current) -> String {
        (self as NSNumber).formattedCurrency(locale: locale)
    }
}

extension NSNumber {
    func formattedCurrency(
        locale: Locale = .current,
        with style: NumberFormatter.Style = .currency
    ) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = style
        formatter.locale = locale
        formatter.currencyCode = locale.currency?.identifier
        
        let isInteger = floor(doubleValue) == doubleValue
        formatter.minimumFractionDigits = isInteger ? 0 : 2

        if abs(doubleValue).isLess(than: 1) {
            formatter.maximumFractionDigits = 4
        }
        return formatter.string(from: self) ?? ""
    }
}
