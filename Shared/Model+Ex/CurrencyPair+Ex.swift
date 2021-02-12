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
            return (1 / USD).formattedCurrency()
        case .EUR:
            return (1 / EUR).formattedCurrency()
        default:
            return ""
        }
    }
}
