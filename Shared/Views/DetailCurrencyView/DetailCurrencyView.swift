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
                    Text("Refill".localized)
                    Spacer()
                    if viewModel.currency != .RUB {
                        TextField("Average".localized.lowercased(), text: $viewModel.averagePayIn.value)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.center)
                            .fixedSize()
                    }

                    CurrencyText(money: viewModel.payIn)
                }
                CurrencyRow(label: "Withdrawal".localized, money: viewModel.payOut)
            }
            if viewModel.operations.contains { $0.operationType == .Buy } {
                Section {
                    CurrencyRow(label: "Average price purchase".localized, money: viewModel.avgBuy)
                    CurrencyRow(label: "Total purchased".localized, money: viewModel.totalBuy)
                    CurrencyRow(label: "Total spent".localized, money: viewModel.totalSellRUB)
                    CurrencyRow(label: "Total commission".localized, money: viewModel.totalCommision)
                }
            }

            Section {
                if viewModel.avg.value.isNormal {
                    CurrencyRow(label: "Average".localized, money: viewModel.avg)
                }
                CurrencyRow(label: "Total".localized, money: viewModel.total)
            }
        }

        .listStyle(GroupedListStyle())
        .navigationTitle(viewModel.currency.rawValue)
    }
}
