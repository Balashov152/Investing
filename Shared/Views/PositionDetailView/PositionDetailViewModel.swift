//
//  PositionDetailViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Combine
import InvestModels
import SwiftUI

protocol PositionDetailModel {
    var currency: Currency { get }
    var totalCount: PositionDetailViewModel.ChangeOperation { get }
    var name: String? { get }
    var ticker: String { get }
}

extension PositionView: PositionDetailModel {
    var totalCount: PositionDetailViewModel.ChangeOperation {
        .init(count: Int(lots), money: totalInProfile)
    }
}

class PositionDetailViewModel: EnvironmentCancebleObject, ObservableObject {
    let position: PositionDetailModel
    var currency: Currency { position.currency }

    @Published var blocked: String {
        willSet {
            env.settings.blockedPosition[position.ticker] = Double(newValue)?.addCurrency(currency)
        }
    }

    @Published var operations: [Operation] = []

    init(position: PositionDetailModel, env: Environment) {
        self.position = position

        if let savedBlocked = env.settings.blockedPosition[position.ticker] {
            blocked = savedBlocked.convert(to: position.currency,
                                           pair: CurrencyPairServiceLatest.shared.latest).value.string(f: ".2")
        } else {
            blocked = ""
        }

        super.init(env: env)
    }

    override func bindings() {
        super.bindings()
        env.api().operationsService.$operations
            .removeDuplicates()
            .receive(on: DispatchQueue.global())
            .map { [unowned self] operations in
                operations.filter { $0.instrument?.ticker == position.ticker }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.operations, on: self)
            .store(in: &cancellables)
    }

    public func load() {
//        env.api().operationsService.getOperations(request: .init(env: env))
    }
}

extension PositionDetailViewModel {
    var dividends: MoneyAmount {
        operations.filter(types: [.Coupon, .Dividend]).currencySum(to: currency)
    }

    var total: MoneyAmount {
        position.totalCount.money + operations.currencySum(to: position.currency)
    }

    var buyCount: ChangeOperation {
        let filtered = operations.filter(types: [.Buy, .BuyCard])
        let count = filtered.reduce(0) { $0 + $1.quantityExecuted }
        return ChangeOperation(count: count,
                               money: abs(filtered.currencySum(to: currency).value).addCurrency(currency))
    }

    var sellCount: ChangeOperation {
        let filtered = operations.filter(types: [.Sell])
        let count = filtered.reduce(0) { $0 + $1.quantityExecuted }
        return ChangeOperation(count: count,
                               money: filtered.currencySum(to: currency))
    }

    var inProfile: ChangeOperation { position.totalCount }

    var totalBuy: ChangeOperation {
        ChangeOperation(count: buyCount.count - sellCount.count,
                        money: buyCount.money - sellCount.money)
    }

    var average: MoneyAmount {
        MoneyAmount(currency: position.currency,
                    value: totalBuy.money.value / Double(inProfile.count))
    }
}

extension PositionDetailViewModel {
    struct ChangeOperation {
        let count: Int
        let money: MoneyAmount
    }
}
