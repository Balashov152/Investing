//
//  CurrencyView.swift
//  Investing
//
//  Created by Sergey Balashov on 11.12.2020.
//

import Combine
import InvestModels
import SwiftUI

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
        .navigationTitle("Currency".localized)
        .onAppear(perform: viewModel.loadOperaions)
    }

    struct RowView: View {
        let row: CurrencyViewModel.Row

        var body: some View {
            HStack {
                Text(row.currency.rawValue)
                Spacer()
                Text("Operations".localized.lowercased())
                Text(row.operations.count.string)
            }
        }
    }

    struct CurrencyOperationView: View {
        let operation: Operation
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(operation.operationType.rawValue)
                            .font(.system(size: 17, weight: .bold))
                        Text(operation.date.string(format: "dd.MM.yy HH:mm"))
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
