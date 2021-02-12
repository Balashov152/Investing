//
//  DetailCurrencyView.swift
//  Investing
//
//  Created by Sergey Balashov on 15.01.2021.
//

import Combine
import InvestModels
import SwiftUI

struct DetailCurrencyView: View {
    @ObservedObject var viewModel: DetailCurrencyViewModel

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Pay in")
                    Spacer()
                    if viewModel.currency != .RUB {
                        TextField("average", text: $viewModel.averagePayIn.value)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.center)
                            .fixedSize()
                    }

                    CurrencyText(money: viewModel.payIn)
                }
                CurrencyRow(label: "Pay out", money: viewModel.payOut)
            }
            if viewModel.operations.contains { $0.operationType == .Buy } {
                Section {
                    CurrencyRow(label: "Average buy", money: viewModel.avgBuy)
                    CurrencyRow(label: "Total buy", money: viewModel.totalBuy)
                    CurrencyRow(label: "Total spent", money: viewModel.totalSellRUB)
                    CurrencyRow(label: "Total comission", money: viewModel.totalCommision)
                }
            }

            Section {
                if viewModel.avg.value.isNormal {
                    CurrencyRow(label: "Average", money: viewModel.avg)
                }

//                CurrencyRow(label: "Total spent", money: viewModel.totalSellRUB)
                CurrencyRow(label: "Total", money: viewModel.total)
            }
        }

        .listStyle(GroupedListStyle())
        .navigationTitle(viewModel.currency.rawValue)
    }
}
