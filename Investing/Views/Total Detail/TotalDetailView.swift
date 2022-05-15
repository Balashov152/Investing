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
        Group {
            switch viewModel.loading {
            case .loaded:
                list
            case .loading:
                ProgressView()
            case let .failure(error):
                Text(error.localizedDescription)
            }
        }
        .onAppear(perform: viewModel.load)
        .navigationTitle("Total".localized)
    }

    var list: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Analytic portfolio".localized)
                        .font(.title)
                    Text("All information about you deals(buy and sell) on selected period. All values did present after convert to selected currency".localized + " - ") + Text(viewModel.currency.rawValue).bold()
                        .font(.body)
                }
            }
            Section {
                MoneyRow(label: "Total purchased".localized, money: viewModel.totalBuy)
                MoneyRow(label: "Total sold".localized, money: viewModel.totalSell)
                MoneyRow(label: "Total in investment".localized, money: viewModel.inWork)

                MoneyRow(label: "Total for all time".localized, money: viewModel.total)
            }

            Section {
                MoneyRow(label: "Dividends".localized, money: viewModel.dividends)
                MoneyRow(label: "Total with dividends".localized, money: viewModel.total + viewModel.dividends)
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
        .listStyle(GroupedListStyle())
    }
}
