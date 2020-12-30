//
//  CurrencyView.swift
//  Investing
//
//  Created by Sergey Balashov on 11.12.2020.
//

import Combine
import InvestModels
import SwiftUI

class CurrencyViewModel: EnvironmentCancebleObject, ObservableObject {
    @Published var sections: [Section] = []
    @Published var sellRUB = MoneyAmount(currency: .RUB, value: 0)
    @Published var buyUSD = MoneyAmount(currency: .USD, value: 0)

    var total: Set<Total> = []

    struct Total: Hashable {
        let cur: Currency
        let value: Double
    }

    let filterBuyUsd: ((Operation) -> Bool) = {
        $0.instrument?.currency == .some(.RUB) &&
            $0.instrument?.type == .some(.Currency) &&
            $0.operationType == .some(.Buy) &&
            $0.currency == .RUB
    }

    let currences: [Currency] = [.RUB, .USD, .EUR]

    override func bindings() {
        env.operationsService.$operations
            .receive(on: DispatchQueue.global())
            .map { [unowned self] operations in
                mapToSections(operations: operations)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.sections, on: self)
            .store(in: &cancellables)

        let buyUSDOperations = env.operationsService.$operations
            .receive(on: DispatchQueue.global())
            .map { $0.filter(self.filterBuyUsd) }
            .share()

        buyUSDOperations
            .map { MoneyAmount(currency: .RUB, value: $0.sum) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.sellRUB, on: self)
            .store(in: &cancellables)

        buyUSDOperations
            .map { MoneyAmount(currency: .USD,
                               value: $0.reduce(0) { $0 + Double($1.quantityExecuted) }) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.buyUSD, on: self)
            .store(in: &cancellables)
    }

    public func loadOperaions() {
        env.operationsService.getOperations(request: .init(env: env))
    }

    func mapToSections(operations: [Operation]) -> [Section] {
        guard !operations.isEmpty else {
            return []
        }
        return currences.compactMap { currency -> Section? in
            let operationForType = operations.filter { $0.currency == currency }
            let payIn = operationForType.filter { $0.operationType == .some(.PayIn) }.sum
            let payOut = operationForType.filter { $0.operationType == .some(.PayOut) }.sum

            let rows = Section.RowType.allCases.map { type -> Section.Row in
                switch type {
                case .payIn:
                    return Section.Row(title: type,
                                       value: .init(currency: currency, value: payIn))
                case .payOut:
                    return Section.Row(title: type,
                                       value: .init(currency: currency, value: payOut))
                case .total:
                    return Section.Row(title: type,
                                       value: .init(currency: currency, value: payIn + payOut))
                }
            }
            return Section(currency: currency, rows: rows)
        }
    }
}

extension CurrencyViewModel {
    struct Section: Hashable {
        let currency: Currency
        let rows: [Row]

        struct Row: Hashable {
            let title: RowType
            let value: MoneyAmount
        }

        enum RowType: String, Hashable, CaseIterable {
            case payIn, payOut, total

            var name: String {
                switch self {
                case .payIn:
                    return "Pay in"
                case .payOut:
                    return "Pay out"
                case .total:
                    return "Total"
                }
            }
        }
    }
}

struct CurrencyView: View {
    @ObservedObject var viewModel: CurrencyViewModel

    var body: some View {
        List {
            Section(header: Text("Buy currency").font(.title)) {
                commisionCell(label: "Sell RUB", money: viewModel.sellRUB)
                commisionCell(label: "Buy USD", money: viewModel.buyUSD)
            }

            ForEach(viewModel.sections, id: \.self) { section in
                Section(header: Text(section.currency.rawValue).font(.title)) {
                    ForEach(section.rows, id: \.self) { currency in
                        commisionCell(label: currency.title.name, money: currency.value)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Currency")
        .onAppear(perform: viewModel.loadOperaions)
    }

    func commisionCell(label: String, money: MoneyAmount) -> some View {
        HStack {
            Text(label)
            Spacer()
            MoneyText(money: money)
        }
    }
}
