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
                PosotionInfoRow(label: "Total purchases".localized, changes: viewModel.buyCount)
                PosotionInfoRow(label: "Total of sold".localized, changes: viewModel.sellCount)

                PosotionInfoRow(label: "Now in portfolio".localized, changes: viewModel.inProfile)
            }

            Section {
                CurrencyRow(label: "Average".localized, money: viewModel.average)

                if viewModel.dividends.value > 0 {
                    MoneyRow(label: "Dividends", money: viewModel.dividends)
                }

                MoneyRow(label: "Result of operations".localized, money: viewModel.total)
            }

            Section {
                DisclosureGroup(content: {
                    ForEach(viewModel.operations, id: \.self) {
                        OperationRowView(operation: $0)
                    }
                }, label: {
                    Text("All operations".localized + " " + viewModel.operations.count.string)
                })
            }
        }
        .onAppear(perform: viewModel.load)
        .listStyle(GroupedListStyle())
        .navigationTitle(viewModel.position.name.orEmpty)
    }
}
