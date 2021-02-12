//
//  CurrencyView.swift
//  Investing
//
//  Created by Sergey Balashov on 11.12.2020.
//

import Combine
import InvestModels
import SwiftUI

private extension Operation {
    var opCurrency: Currency {
        guard let ticker = instrument?.ticker else {
            return currency
        }

        return Currency.allCases.first(where: {
            ticker.starts(with: $0.rawValue)
        }) ?? currency
    }
}

class CurrencyViewModel: EnvironmentCancebleObject, ObservableObject {
    @Published var rows: [Row] = []
    struct Row: Hashable {
        let currency: Currency
        let operations: [Operation]
    }

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
        env.operationsService
            .getOperations(request: .init(env: env))
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
            ForEach(viewModel.rows, id: \.self) { row in
                NavigationLink(
                    destination: ViewFactory.detailCurrencyView(currency: row.currency,
                                                                operations: row.operations,
                                                                env: viewModel.env),
                    label: {
                        RowView(row: row)
                    }
                )
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Currency")
        .onAppear(perform: viewModel.loadOperaions)

        //            Section(header: Text("Buy currency").font(.title)) {
        //                commisionCell(label: "Sell RUB", money: viewModel.sellRUB)
        //                commisionCell(label: "Buy USD", money: viewModel.buyUSD)
        //            }
        //
        //            ForEach(viewModel.sections, id: \.self) { section in
        //                Section(header: Text(section.currency.rawValue).font(.title)) {
        //                    ForEach(section.rows, id: \.self) { currency in
        //                        commisionCell(label: currency.title.name, money: currency.value)
        //                    }
        //                }
        //            }
    }

    struct RowView: View {
        let row: CurrencyViewModel.Row

        var body: some View {
            HStack {
                Text(row.currency.rawValue)
                Spacer()
                Text("operations")
                Text(row.operations.count.string)
            }
        }
    }

    struct CurrencyOperationView: View {
        let operation: Operation
        var body: some View {
            VStack(alignment: .leading) {
//                Text(operation.opCurrency.rawValue)
//                    .font(.system(size: 17, weight: .bold))

                HStack {
                    VStack(alignment: .leading) {
                        Text(operation.operationType.rawValue)
                            .font(.system(size: 17, weight: .bold))
                        Text(DateFormatter.format("dd.MM.yy HH:mm").string(from: operation.date))
                            .font(.system(size: 13))
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        if let payment = operation.payment, let currency = operation.currency {
                            CurrencyText(money: MoneyAmount(currency: currency, value: payment))
                        }
                        if let commission = operation.commission {
                            CurrencyText(money: commission)
                                .foregroundColor(.gray)
                        }
                    }.font(.system(size: 14))
                }
            }
        }
    }
}
