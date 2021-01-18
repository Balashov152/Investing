//
//  DetailCurrencyView.swift
//  Investing
//
//  Created by Sergey Balashov on 15.01.2021.
//

import Combine
import InvestModels
import SwiftUI

class TextLimiter: ObservableObject {
    private let limit: Int

    init(limit: Int) {
        self.limit = limit
    }

    @Published var value = "" {
        didSet {
            if value.count > limit {
                value = String(value.prefix(limit))
                hasReachedLimit = true
            } else {
                hasReachedLimit = false
            }
        }
    }

    @Published var hasReachedLimit = false
}

class DetailCurrencyViewModel: EnvironmentCancebleObject, ObservableObject {
    let currency: Currency
    let operations: [Operation]

    @Published var averagePayIn = TextLimiter(limit: 3)

    // Total

    // In / Out
    var payIn: MoneyAmount {
        return MoneyAmount(currency: currency,
                           value: operations.filter { $0.operationType == .PayIn }
                               .reduce(0) { result, operation in
                                   result + operation.payment
                               })
    }

    var payOut: MoneyAmount {
        return MoneyAmount(currency: currency,
                           value: operations.filter { $0.operationType == .PayOut }
                               .reduce(0) { result, operation in
                                   result + operation.payment
                               })
    }

    // Buy
    var avgBuy: MoneyAmount {
        let avg = abs(totalSellRUB.value) / totalBuy.value
        return MoneyAmount(currency: currency, value: avg)
    }

    var totalBuy: MoneyAmount {
        return MoneyAmount(currency: currency,
                           value: Double(buyOperations.reduce(0) { $0 + $1.quantityExecuted }))
    }

    var totalSellRUB: MoneyAmount {
        return MoneyAmount(currency: .RUB,
                           value: Double(buyOperations.reduce(0) { $0 + $1.payment }))
    }

    var totalCommision: MoneyAmount {
        return MoneyAmount(currency: .RUB,
                           value: Double(buyOperations.reduce(0) { $0 + ($1.commission?.value ?? 0) }))
    }

    var buyOperations: [Operation] {
        operations.filter { $0.operationType == .Buy }
    }

    init(currency: Currency, operations: [Operation], env: Environment) {
        self.currency = currency
        self.operations = operations

        super.init(env: env)

        averagePayIn.value = Storage.payInAvg?.formattedCurrency() ?? ""
    }

    override func bindings() {
        super.bindings()
        averagePayIn.$value.map(Double.init).filter { $0 != nil }
            .sink { value in
                Storage.payInAvg = value
            }.store(in: &cancellables)
    }

    // Total

    var avg: MoneyAmount {
        var avg = avgBuy.value
        if let inAvg = Double(averagePayIn.value) {
            let inSpent = payIn.value * inAvg
            let out = payOut.value * avgBuy.value

            avg = inSpent + abs(totalSellRUB.value) + out
            avg /= total.value
        }
        return MoneyAmount(currency: currency, value: avg)
    }

    var total: MoneyAmount {
        let avg = totalBuy.value + payIn.value + payOut.value
        return MoneyAmount(currency: currency, value: avg)
    }
}

struct DetailCurrencyView: View {
    @ObservedObject var viewModel: DetailCurrencyViewModel

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Pay in")
                    Spacer()
                    TextField("average", text: $viewModel.averagePayIn.value)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.center)
                        .fixedSize()

                    CurrencyText(money: viewModel.payIn)
                }
                CurrencyRow(label: "Pay out", money: viewModel.payOut)
            }
            Section {
                CurrencyRow(label: "Average buy", money: viewModel.avgBuy)
                CurrencyRow(label: "Total buy", money: viewModel.totalBuy)
                CurrencyRow(label: "Total spent", money: viewModel.totalSellRUB)
                CurrencyRow(label: "Total comission", money: viewModel.totalCommision)
            }

            Section {
                CurrencyRow(label: "Average", money: viewModel.avg)
//                CurrencyRow(label: "Total buy", money: viewModel.totalBuy)
//                CurrencyRow(label: "Total spent", money: viewModel.totalSellRUB)
                CurrencyRow(label: "Total", money: viewModel.total)
            }
        }

        .listStyle(GroupedListStyle())
        .navigationTitle(viewModel.currency.rawValue)
    }
}

struct CurrencyRow: View {
    let label: String
    let money: MoneyAmount

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            CurrencyText(money: money)
        }
    }
}
