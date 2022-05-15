//
//  PayInViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 12.02.2021.
//

import Foundation
import InvestModels

extension PayInViewModel {
    typealias Section = PayInService.Year
    typealias Month = PayInService.Month
    typealias Row = PayInService.PayOperation
}

extension PayInViewModel.Month {
    var header: String {
        guard let row = operations.first?.date else {
            return "no rows"
        }
        return DateFormatter
            .format("LLLL").string(from: row).capitalized
    }
}

extension PayInViewModel.Row {
    var localizedDate: String {
        DateFormatter.format("dd MMMM").string(from: date)
    }
}

class PayInViewModel: EnvironmentCancebleObject, ObservableObject {
    @Published var sections: [Section] = []
    let payInService: PayInService

    override init(env: Environment = .current) {
        payInService = .init(env: env)
        super.init(env: env)
    }

    var currency: Currency {
        env.settings.currency ?? .RUB
    }

    public func load() {
        env.api().operationsService.getOperations(request: .init(env: env))
    }

    override func bindings() {
        super.bindings()
        env.api().operationsService.$operations
            .receive(on: DispatchQueue.global())
            .map { [unowned self] operations in
                payInService.payInOut(operations: operations)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.sections, on: self)
            .store(in: &cancellables)
    }
}
