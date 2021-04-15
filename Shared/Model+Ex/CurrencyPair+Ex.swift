//
//  CurrencyPair+Ex.swift
//  Investing
//
//  Created by Sergey Balashov on 12.02.2021.
//

import Foundation
import InvestModels

extension CurrencyPair {
    func localized(currency: Currency) -> String {
        switch currency {
        case .USD:
            return USD.formattedCurrency()
        case .EUR:
            return EUR.formattedCurrency()
        default:
            return ""
        }
    }
}
