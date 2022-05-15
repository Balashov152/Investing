//
//  DetailCurrencyViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 12.02.2021.
//

import Combine
import InvestModels
import SwiftUI

class DetailCurrencyViewModel: EnvironmentCancebleObject, ObservableObject {
    let currency: Currency
    let operations: [Operation]

    @Published var averagePayIn = TextLimiter(limit: 5)

    // Total
    // In / Out
    var payIn: MoneyAmount {
        return MoneyAmount(currency: currency,
                           value: operations.filter { $0.operationType == .PayIn }
                               .reduce(0) { $0 + $1.payment })
    }

    var payOut: MoneyAmount {
        return MoneyAmount(currency: currency,
                           value: operations.filter { $0.operationType == .PayOut }
                               .reduce(0) { $0 + $1.payment })
    }

    // Buy
    var avgBuy: MoneyAmount {
        let avg = abs(totalSellRUB.value) / totalBuy.value
        return MoneyAmount(currency: currency, value: avg)
    }

    var totalBuy: MoneyAmount {
        return MoneyAmount(currency: currency,
                           value: Double(buyOperations.reduce(0) { $0 + $1.quantityExecuted }))
    }

    var totalSellRUB: MoneyAmount {
        return MoneyAmount(currency: .RUB,
                           value: Double(buyOperations.reduce(0) { $0 + $1.payment }))
    }

    var totalCommision: MoneyAmount {
        return MoneyAmount(currency: .RUB,
                           value: Double(buyOperations.reduce(0) { $0 + ($1.commission?.value ?? 0) }))
    }

    var buyOperations: [Operation] {
        operations.filter { $0.operationType == .Buy }
    }

    init(currency: Currency, operations: [Operation], env: Environment) {
        self.currency = currency
        self.operations = operations

        super.init(env: env)
    }

    override func bindings() {
        super.bindings()
        if currency != .RUB,
           let avg = env.settings.averageCurrency[currency]
        {
            averagePayIn.value = String(avg)
        }

        averagePayIn.$value.dropFirst().map(Double.init)
            .sink { [unowned self] avg in
                if let avg = avg {
                    env.settings.averageCurrency.updateValue(avg, forKey: currency)
                } else {
                    env.settings.averageCurrency.removeValue(forKey: currency)
                }
            }.store(in: &cancellables)
    }

    // Total

    var avg: MoneyAmount {
        if let inAvg = Double(averagePayIn.value) {
            let inOut = payIn + payOut
            let inOutPrice = inOut.value * inAvg

            var newAvg = abs(totalSellRUB.value) + inOutPrice
            debugPrint("newAvg", newAvg, "inOutPrice", inOutPrice)
            newAvg /= total.value

            debugPrint("newAvg", newAvg)
            return MoneyAmount(currency: currency, value: newAvg)

            let inSpent = payIn.value * inAvg
            let out = payOut.value * avgBuy.value
            debugPrint("inSpent", inSpent, "out", out)
            var avg = inSpent + abs(totalSellRUB.value) + out
            debugPrint("avg", avg)

            avg /= total.value

            debugPrint("avg", avg, "total", total.value)
        }
        return MoneyAmount(currency: currency, value: avgBuy.value)
    }

    var total: MoneyAmount {
        let avg = totalBuy.value + payIn.value + payOut.value
        return MoneyAmount(currency: currency, value: avg)
    }
}
