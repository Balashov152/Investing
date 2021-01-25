//
//  ComissionView.swift
//  Investing
//
//  Created by Sergey Balashov on 10.12.2020.
//

import Combine
import InvestModels
import SwiftUI

class ComissionViewModel: EnvironmentCancebleObject, ObservableObject {
//    @Published var operations: [Operation] = []
    @Published var rows: [Row] = []
    @Published var total = MoneyAmount(currency: .RUB, value: 0)

    static let currency = Currency.RUB

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
            .map { [unowned self] operations -> [Row] in
                commissionTypes.compactMap { type -> Row? in
                    switch type {
                    case .BrokerCommission, .ServiceCommission, .MarginCommission:
                        let sum = operations.filter { $0.operationType == .some(type) }
                            .currencySum(to: ComissionViewModel.currency)
                        if sum.value != 0 {
                            return Row(type: type, value: sum)
                        }

                    case .ExchangeCommission, .OtherCommission:
                        let sum = operations
                            .filter { $0.operationType == .some(type) }
                            .currencySum(to: ComissionViewModel.currency)

                        if sum.value != 0 {
                            return Row(type: type, value: sum)
                        }
                    default: break
                    }
                    return nil
                }
            }
            .assign(to: \.rows, on: self)
            .store(in: &cancellables)

        $rows.map { [unowned self] in
            MoneyAmount(currency: ComissionViewModel.currency,
                        value: $0.map { $0.value }.sum)
        }
        .assign(to: \.total, on: self)
        .store(in: &cancellables)
    }
}

extension ComissionViewModel {
    struct Row {
        let type: Operation.OperationTypeWithCommission
        let value: MoneyAmount
    }
}

struct ComissionView: View {
    @StateObject var viewModel: ComissionViewModel

    var body: some View {
        List {
            ForEach(viewModel.rows, id: \.type) { row in
                MoneyRow(label: row.type.rawValue, money: row.value)
            }
            if viewModel.total.value != 0 {
                MoneyRow(label: "Total", money: viewModel.total)
            }
        }
        .navigationTitle("Commissions")
        .onAppear(perform: viewModel.loadOperaions)
    }

    func commisionCell(label: String, double: Double) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(double.formattedCurrency())
                .foregroundColor(.currency(value: double))
        }
    }
}
