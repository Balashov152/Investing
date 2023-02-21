//
//  ComissionViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Combine
import InvestModels
import SwiftUI

class ComissionViewModel: EnvironmentCancelableObject, ObservableObject {
    @Published var rows: [Row] = []
    @Published var total = MoneyAmount(currency: .RUB, value: 0)

    var currency: Currency { env.settings.currency ?? .RUB }

    let commissionTypes: [Operation.OperationTypeWithCommission] = [
        .BrokerCommission, .ServiceCommission, .MarginCommission,
        .ExchangeCommission, .OtherCommission,
    ]

    public func loadOperaions() {
        env.operationsService.getOperations(request: .init(env: env))
    }

    override func bindings() {
        super.bindings()
        env.operationsService.$operations
            .receive(on: DispatchQueue.global())
            .map { [unowned self] operations -> [Row] in
                commissionTypes.compactMap { [unowned self] type -> Row? in
                    switch type {
                    case .BrokerCommission, .ServiceCommission, .MarginCommission:
                        let sum = operations.filter { $0.operationType == .some(type) }
                            .currencySum(to: currency)
                        if sum.value != 0 {
                            return Row(type: type, value: sum)
                        }

                    case .ExchangeCommission, .OtherCommission:
                        let sum = operations
                            .filter { $0.operationType == .some(type) }
                            .currencySum(to: currency)

                        if sum.value != 0 {
                            return Row(type: type, value: sum)
                        }
                    default: break
                    }
                    return nil
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.rows, on: self)
            .store(in: &cancellables)

        $rows.map { [unowned self] in
            MoneyAmount(currency: currency, value: $0.map { $0.value }.sum)
        }
        .assign(to: \.total, on: self)
        .store(in: &cancellables)
    }
}

extension ComissionViewModel {
    struct Row {
        let type: Operation.OperationTypeWithCommission
        let value: MoneyAmount

        var title: String {
            switch type {
            case .BrokerCommission:
                return "Брокерская комиссия"
            case .ServiceCommission:
                return "Сервисное обслуживание"
            case .MarginCommission:
                return "Перенос позиций"
            case .ExchangeCommission:
                return "Комиссия обмена"
            case .OtherCommission:
                return "Другая комиссия"
            default:
                assertionFailure("not implement case")
                return "Комиссия"
            }
        }
    }
}
