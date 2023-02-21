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
    func formattedCurrency(locale: Locale = .current,
                           with style: NumberFormatter.Style = .currency) -> String
    {
        let formater = NumberFormatter()
//        formater.usesGroupingSeparator = true
        formater.groupingSeparator = " "
        formater.numberStyle = style
        formater.locale = locale
        let isInteger = floor(doubleValue) == doubleValue
        formater.minimumFractionDigits = isInteger ? 0 : 2

        if abs(doubleValue).isLess(than: 1) {
            formater.maximumFractionDigits = 4
        }
        return formater.string(from: self) ?? ""
    }
}
