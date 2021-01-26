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
