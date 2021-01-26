//
//  TotalDetailViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Combine
import Foundation
import InvestModels
import SwiftUI

class TotalDetailViewModel: EnvironmentCancebleObject, ObservableObject {
    @Published var operations: [Operation] = []
    @Published var positions: [Position] = []

    var currencyPairServiceLatest: CurrencyPairServiceLatest { .shared }
    var currency: Currency {
        env.settings.currency ?? .RUB
    }

    var totalSell: MoneyAmount {
        operations.filter(types: [.Sell]).currencySum(to: currency)
    }

    var totalBuy: MoneyAmount {
        operations.filter(types: [.Buy, .BuyCard]).currencySum(to: currency)
    }

    var inWork: MoneyAmount {
        let value = positions.reduce(0) {
            $0 + CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                money: $1.totalInProfile,
                                                to: currency).value
        }
        return MoneyAmount(currency: currency, value: value)
    }

    var dividends: MoneyAmount {
        let value = operations.filter(type: .Dividend).reduce(0) {
            $0 + CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                money: $1.payment.addCurrency($1.currency),
                                                to: currency).value
        }
        return MoneyAmount(currency: currency, value: value)
    }

    var total: MoneyAmount {
        totalSell + totalBuy + inWork
    }

    override func bindings() {
        super.bindings()
        env.api().operationsService.$operations
            .receive(on: DispatchQueue.global())
            .map { operations in
                operations.filter(types: [.Sell, .Buy, .BuyCard, .Dividend])
                    .filter { $0.instrumentType != .some(.Currency) }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.operations, on: self)
            .store(in: &cancellables)
    }

    public func load() {
        env.api().operationsService.getOperations(request: .init(env: env))

        env.api().positionService.getPositions()
            .replaceError(with: [])
            .assign(to: \.positions, on: self)
            .store(in: &cancellables)
    }
}
