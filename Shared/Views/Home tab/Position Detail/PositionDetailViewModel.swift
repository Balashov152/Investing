//
//  PositionDetailViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Combine
import InvestModels
import SwiftUI

class PositionDetailViewModel: EnvironmentCancebleObject, ObservableObject {
    let position: PositionView

    @Published var operations: [Operation] = []

    var total: MoneyAmount {
        position.totalInProfile + operations.currencySum(to: position.currency)
    }

    var buyCount: ChangeOperation {
        let filtered = operations.filter(types: [.Buy, .BuyCard])
        let count = filtered.reduce(0) { $0 + $1.quantityExecuted }
        return ChangeOperation(count: count,
                               money: abs(filtered.sum).addCurrency(position.currency))
    }

    var sellCount: ChangeOperation {
        let filtered = operations.filter(types: [.Sell])
        let count = filtered.reduce(0) { $0 + $1.quantityExecuted }
        return ChangeOperation(count: count,
                               money: filtered.sum.addCurrency(position.currency))
    }

    var inProfile: ChangeOperation {
        ChangeOperation(count: buyCount.count - sellCount.count,
                        money: buyCount.money - sellCount.money)
    }

    var average: MoneyAmount {
        MoneyAmount(currency: position.currency,
                    value: inProfile.money.value / Double(inProfile.count))
    }

    init(position: PositionView, env: Environment) {
        self.position = position

        super.init(env: env)
    }

    override func bindings() {
        super.bindings()
        env.api().operationsService.$operations
            .receive(on: DispatchQueue.global())
            .map { [unowned self] operations in
                operations.filter { $0.instrument?.ticker == position.ticker }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.operations, on: self)
            .store(in: &cancellables)
    }

    public func load() {
        env.api().operationsService.getOperations(request: .init(env: env))
    }
}

extension PositionDetailViewModel {
    struct ChangeOperation {
        let count: Int
        let money: MoneyAmount
    }
}
