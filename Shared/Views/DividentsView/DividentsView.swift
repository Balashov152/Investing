//
//  DividentsView.swift
//  Investing
//
//  Created by Sergey Balashov on 25.12.2020.
//
import Combine
import InvestModels
import SwiftUI

struct DividentsView: View {
    @ObservedObject var viewModel: DividentsViewModel

    var body: some View {
        List {
            Section {
                MoneyRow(label: "Total dividends".localized,
                         money: viewModel.dividents.filter(type: .Dividend)
                             .currencySum(to: .RUB))

                MoneyRow(label: "Total tax".localized,
                         money: viewModel.dividents.filter(type: .TaxDividend)
                             .currencySum(to: .RUB))
            }

            Section {
                ForEach(viewModel.instruments, id: \.self) { instrument in
                    let operations = viewModel.dividents
                        .filter { $0.instrument == instrument }
                        .sorted(by: { $0.date < $1.date })

                    DisclosureGroup(content: {
                        ForEach(operations, id: \.self) { operation in
                            Row(operation: operation)
                        }
                    }, label: {
                        MoneyRow(label: instrument.name,
                                 money: operations.currencySum(to: instrument.currency))
                    })
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Dividends".localized)
        .onAppear(perform: viewModel.loadOperaions)
    }

    struct Row: View {
        let operation: Operation

        var body: some View {
            VStack(alignment: .leading) {
                if operation.operationType == .some(.Dividend) {
                    CurrencyRow(label: "Dividend".localized,
                                money: MoneyAmount(currency: operation.currency,
                                                   value: operation.payment))
                } else if operation.operationType == .some(.TaxDividend) {
                    CurrencyRow(label: "Dividend tax".localized,
                                money: MoneyAmount(currency: operation.currency,
                                                   value: operation.payment))
                }
                Text(operation.date.string(format: "HH:mm dd MMMM yyyy"))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.gray)
            }.padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        }
    }
}
