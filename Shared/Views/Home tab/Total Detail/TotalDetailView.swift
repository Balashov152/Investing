//
//  TotalDetailView.swift
//  InvestModels
//
//  Created by Sergey Balashov on 25.01.2021.
//

import Combine
import Foundation
import InvestModels
import SwiftUI

class TotalDetailViewModel: EnvironmentCancebleObject, ObservableObject {
    @Published var operations: [Operation] = []
    @Published var positions: [Position] = []

    var currencyPairServiceLatest: CurrencyPairServiceLatest { .shared }
    var currency: Currency {
        env.settings().currency ?? .RUB
    }

    var totalSell: MoneyAmount {
        operations.filter(types: [.Sell]).currencySum(to: currency)
    }

    var totalBuy: MoneyAmount {
        operations.filter(types: [.Buy, .BuyCard]).currencySum(to: currency)
    }

    var inWork: MoneyAmount {
        let value = positions.reduce(0) {
            $0 + CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                money: $1.totalInProfile,
                                                to: currency).value
        }
        return MoneyAmount(currency: currency, value: value)
    }

    var dividends: MoneyAmount {
        let value = operations.filter(type: .Dividend).reduce(0) {
            $0 + CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                money: $1.payment.addCurrency($1.currency),
                                                to: currency).value
        }
        return MoneyAmount(currency: currency, value: value)
    }

    var total: MoneyAmount {
        totalSell + totalBuy + inWork
    }

    override func bindings() {
        super.bindings()
        env.api().operationsService.$operations
            .receive(on: DispatchQueue.global())
            .map { operations in
                operations.filter(types: [.Sell, .Buy, .BuyCard, .Dividend])
                    .filter { $0.instrumentType != .some(.Currency) }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.operations, on: self)
            .store(in: &cancellables)
    }

    public func load() {
        env.api().operationsService.getOperations(request: .init(env: env))

        env.api().positionService.getPositions()
            .replaceError(with: [])
            .assign(to: \.positions, on: self)
            .store(in: &cancellables)
    }
}

struct TotalDetailView: View {
    @ObservedObject var viewModel: TotalDetailViewModel

    var body: some View {
        List {
            Section {
                MoneyRow(label: "Total all buy", money: viewModel.totalBuy)
                MoneyRow(label: "Total all sell", money: viewModel.totalSell)
                MoneyRow(label: "Total in instruments", money: viewModel.inWork)

                MoneyRow(label: "Total all time", money: viewModel.total)
            }

            Section {
                MoneyRow(label: "Dividends", money: viewModel.dividends)
                MoneyRow(label: "Total with dividends", money: viewModel.total + viewModel.dividends)
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
        .navigationTitle("Total")
    }
}
