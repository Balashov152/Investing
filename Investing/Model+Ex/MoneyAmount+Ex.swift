//
//  MoneyAmount+Ex.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Foundation
import InvestModels

extension Collection where Element == MoneyAmount {
    var sum: Double {
        map { $0.value }.reduce(0, +)
    }

    var moneySum: MoneyAmount? {
        let currencires = map { $0.currency }.unique
        guard currencires.count == 1, let currency = currencires.first else {
            return nil
        }
        return MoneyAmount(currency: currency, value: sum)
    }
}
