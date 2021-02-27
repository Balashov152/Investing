//
//  OperationSum.swift
//  Investing
//
//  Created by Sergey Balashov on 21.12.2020.
//

import Foundation
import InvestModels

extension Operation {
    var money: MoneyAmount {
        MoneyAmount(currency: currency, value: payment)
    }

    var opCurrency: Currency {
        guard let ticker = instrument?.ticker else {
            return currency
        }

        return Currency.allCases.first(where: {
            ticker.starts(with: $0.rawValue)
        }) ?? currency
    }
}

extension Collection where Element == Operation {
    func totalSell(to currency: Currency) -> MoneyAmount {
        filter(types: [.Sell]).currencySum(to: currency)
    }

    func totalBuy(to currency: Currency) -> MoneyAmount {
        filter(types: [.Buy, .BuyCard]).currencySum(to: currency)
    }
    
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
