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
