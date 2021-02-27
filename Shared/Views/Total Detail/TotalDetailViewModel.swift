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
    @Published var loading = LoadingState<([Operation], [Position])>.loading

    var positions: [Position] { loading.object?.1 ?? [] }
    var operations: [Operation] { loading.object?.0 ?? [] }

    var currencyPairServiceLatest: CurrencyPairServiceLatest { .shared }
    var currency: Currency {
        env.settings.currency ?? .RUB
    }

    var totalSell: MoneyAmount {
        operations.totalSell(to: currency)
    }

    var totalBuy: MoneyAmount {
        operations.totalBuy(to: currency)
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
        Publishers.CombineLatest(env.api().operationsService.$operations.dropFirst(),
                                 env.api().positionService.$positions.dropFirst())
            .receive(on: DispatchQueue.global())
            .map { operations, positions in
                let filtered = operations
                    .filter(types: [.Sell, .Buy, .BuyCard, .Dividend])
                    .filter { $0.instrumentType != .some(.Currency) }

                return .loaded(object: (filtered, positions))
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.loading, on: self)
            .store(in: &cancellables)
    }

    public func load() {
        env.api().operationsService.getOperations(request: .init(env: env))
        env.api().positionService.getPositions()
    }
}
