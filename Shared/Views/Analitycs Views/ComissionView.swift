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
    @Published var total: Double = 0.0

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
                        let sum = operations.filter { $0.operationType == .some(type) }.envSum(env: env)
                        if sum != 0 {
                            return Row(type: type, value: sum)
                        }

                    case .ExchangeCommission, .OtherCommission:
                        let sum = operations
                            .filter { $0.operationType == .some(type) }
                            .compactMap { operation -> MoneyAmount? in
                                if let commission = operation.commission {
                                    return operation.convert(money: commission, to: env.currency())
                                }
                                return nil
                            }.map { $0.value }.sum

                        if sum != 0 {
                            return Row(type: type, value: sum)
                        }
                    default: break
                    }
                    return nil
                }
            }
            .assign(to: \.rows, on: self)
            .store(in: &cancellables)

        $rows
            .map { $0.map { $0.value }.sum }
            .assign(to: \.total, on: self)
            .store(in: &cancellables)
    }
}

extension ComissionViewModel {
    struct Row {
        let type: Operation.OperationTypeWithCommission
        let value: Double
    }
}

struct ComissionView: View {
    @StateObject var viewModel: ComissionViewModel

    var body: some View {
        List {
            ForEach(viewModel.rows, id: \.type) { row in
                commisionCell(label: row.type.rawValue, double: row.value)
            }
            if viewModel.total != 0 {
                commisionCell(label: "Total", double: viewModel.total)
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
