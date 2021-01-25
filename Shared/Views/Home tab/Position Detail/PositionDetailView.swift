//
//  PositionDetailView.swift
//  InvestModels
//
//  Created by Sergey Balashov on 22.01.2021.
//

import Combine
import InvestModels
import SwiftUI

extension Double {
    func addCurrency(_ currency: Currency) -> MoneyAmount {
        .init(currency: currency, value: self)
    }
}

extension MoneyAmount {
    static func + (lhs: MoneyAmount, rhs: MoneyAmount) -> MoneyAmount {
        MoneyAmount(currency: lhs.currency, value: lhs.value + rhs.value)
    }
}

class PositionDetailViewModel: EnvironmentCancebleObject, ObservableObject {
    let position: PositionView

    struct ChangeOperation {
        let count: Int
        let money: MoneyAmount
    }

    @Published var operations: [Operation] = []

    var total: MoneyAmount {
        let value = position.totalInProfile.value + operations.currencySum(to: position.currency).value
        return MoneyAmount(currency: position.currency, value: value)
    }

    var buyCount: ChangeOperation {
        let filtered = operations.filter(types: [.Buy, .BuyCard])
        let count = filtered.reduce(0) { $0 + $1.quantityExecuted }
        return ChangeOperation(count: count,
                               money: filtered.sum.addCurrency(position.currency))
    }

    var sellCount: ChangeOperation {
        let filtered = operations.filter(types: [.Sell])
        let count = filtered.reduce(0) { $0 + $1.quantityExecuted }
        return ChangeOperation(count: count,
                               money: filtered.sum.addCurrency(position.currency))
    }

    var inProfile: ChangeOperation {
        ChangeOperation(count: buyCount.count - sellCount.count,
                        money: buyCount.money + sellCount.money)
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

struct PositionDetailView: View {
    @ObservedObject var viewModel: PositionDetailViewModel

    var body: some View {
        List {
            Section {
                MoneyRow(label: "Total all time", money: viewModel.total)
                PosotionInfoRow(label: "Total buy", changes: viewModel.buyCount)

                PosotionInfoRow(label: "Total sell", changes: viewModel.sellCount)

                PosotionInfoRow(label: "In profile", changes: viewModel.inProfile)
                MoneyRow(label: "In profile tinkoff", money: viewModel.position.totalBuyPayment)

                MoneyRow(label: "Average", money: viewModel.average)
            }
            Section {
                DisclosureGroup(content: {
                    ForEach(viewModel.operations, id: \.self) {
                        OperationRowView(operation: $0)
                    }
                }, label: {
                    Text("All operations \(viewModel.operations.count)")

                })
            }
        }
        .onAppear(perform: viewModel.load)
        .listStyle(GroupedListStyle())
        .navigationTitle(viewModel.position.name.orEmpty)
    }
}

struct PosotionInfoRow: View {
    let label: String
    let changes: PositionDetailViewModel.ChangeOperation

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            CurrencyText(money: changes.money)
            Text(changes.count.string)
        }
    }
}
