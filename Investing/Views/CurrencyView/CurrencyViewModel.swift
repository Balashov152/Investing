//
//  CurrencyViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 12.02.2021.
//

import Combine
import InvestModels
import SwiftUI

class CurrencyViewModel: EnvironmentCancelableObject, ObservableObject {
    @Published var rows: [Row] = []

    override func bindings() {
        super.bindings()
        env.operationsService.$operations
            .receive(on: DispatchQueue.global())
            .map { operations -> [Row] in
                let currencyOps = operations
                    .filter(types: [.PayIn, .PayOut],
                            or: { $0.instrumentType == .some(.Currency) })

                let uniqueCur = currencyOps
                    .map { $0.opCurrency }.unique.sorted(by: >)
                return uniqueCur.map { currency in
                    Row(currency: currency,
                        operations: currencyOps.filter { $0.opCurrency == currency })
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.rows, on: self)
            .store(in: &cancellables)
    }

    public func loadOperaions() {
        env.operationsService.getOperations(request: .init(env: env))
    }
}

extension CurrencyViewModel {
    struct Row: Hashable {
        let currency: Currency
        let operations: [Operation]
    }
}
