//
//  DividentsView.swift
//  Investing
//
//  Created by Sergey Balashov on 25.12.2020.
//
import Combine
import InvestModels
import SwiftUI

class DividentsViewModel: EnvironmentCancebleObject, ObservableObject {
//    @Published var operations: [Operation] = []
    @Published var rows: [Row] = []

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
                        return Row(type: type, value: sum)

                    case .ExchangeCommission, .OtherCommission:
                        let sum = operations.sum
//                            .filter { $0.operationType == .some(type) }
//                            .compactMap {
//                                $0.convert(money: $0.commission, to: env.currency())
//                            }

                        return Row(type: type, value: sum)
                    default:
                        return nil
                    }
                }
            }
            .assign(to: \.rows, on: self)
            .store(in: &cancellables)
    }
}

extension DividentsViewModel {
    struct Row {
        let type: Operation.OperationTypeWithCommission
        let value: Double
    }
}

struct DividentsView: View {
    @ObservedObject var viewModel: ComissionViewModel
    let commissionTypes = [Operation.OperationTypeWithCommission.BrokerCommission,
                           .ExchangeCommission, .ServiceCommission, .MarginCommission, .OtherCommission]

    var body: some View {
        List(viewModel.rows, id: \.type) { row in
            commisionCell(label: row.type.rawValue,
                          double: row.value)
        }.navigationTitle("Commissions")
            .onAppear(perform: viewModel.loadOperaions)
    }

    func commisionCell(label: String, double: Double) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(double.string(f: ".2"))
        }
    }
}
