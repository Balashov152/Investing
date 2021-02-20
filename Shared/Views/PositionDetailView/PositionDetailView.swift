//
//  PositionDetailView.swift
//  InvestModels
//
//  Created by Sergey Balashov on 22.01.2021.
//

import Combine
import InvestModels
import SwiftUI

struct PositionDetailView: View {
    @ObservedObject var viewModel: PositionDetailViewModel

    var body: some View {
        List {
            Section {
                PosotionInfoRow(label: "Total of purchased", changes: viewModel.buyCount)
                PosotionInfoRow(label: "Total of sold", changes: viewModel.sellCount)

                PosotionInfoRow(label: "Now in portfolio", changes: viewModel.inProfile)
            }

            Section {
                CurrencyRow(label: "Average", money: viewModel.average)
                MoneyRow(label: "Result operations", money: viewModel.total)
                if viewModel.dividends.value > 0 {
                    MoneyRow(label: "Dividends", money: viewModel.dividends)
                    MoneyRow(label: "Result operations with dividends", money: viewModel.total + viewModel.dividends)
                }
            }

            Section {
                blockedView
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

    var blockedView: some View {
        HStack(spacing: 8.0) {
            Text("Blocked")
            Spacer(minLength: 40)
            TextField("value", text: $viewModel.blocked)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .modifier(DecimalNumberOnlyViewModifier(text: $viewModel.blocked))

            if !viewModel.blocked.isEmpty {
                Text(viewModel.currency.symbol).bold()
            }
        }
    }
}
