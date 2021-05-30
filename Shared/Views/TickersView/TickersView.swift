//
//  TickersView.swift
//  Investing
//
//  Created by Sergey Balashov on 19.12.2020.
//

import Combine
import InvestModels
import SwiftUI

struct TickersView: View {
    @ObservedObject var viewModel: TickersViewModel

    var body: some View {
        List {
            Section(header: Text("Total".localized)) {
                MoneyRow(label: "Total".localized + " RUB", money: viewModel.totalRUB)
                MoneyRow(label: "Total".localized + " USD", money: viewModel.totalUSD)
                MoneyRow(label: "Total".localized, money: viewModel.total)
            }

            if !viewModel.results.isEmpty {
                ForEach([InstrumentType.Stock, .Bond, .Etf], id: \.self) { type in
                    Section(header: Text(type.pluralName)) {
                        ForEach(viewModel.results.filter { $0.instrument.type == type }) {
                            cell(insturment: $0.instrument, currency: $0.result)
                        }
                    }
                }
            }
        }
        .navigationTitle("Investment".localized)
        .navigationBarItems(trailing: sortView)
        .onAppear(perform: viewModel.loadOperaions)
    }

    func cell(insturment: Instrument, currency: MoneyAmount) -> some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    if let name = insturment.name {
                        Text(name)
                            .font(.system(size: 14, weight: .semibold))
                            .lineLimit(1)
                        if let ticker = insturment.ticker {
                            Text(ticker).font(.system(size: 14))
                        }
                    }
                }
                HStack {
                    if let type = insturment.type {
                        Text(type.rawValue).font(.system(size: 14))
                    }
                }
            }
            Spacer()
            MoneyText(money: currency)
        }
    }

    var sortView: some View {
        Button(viewModel.sortType.localize) {
            viewModel.sortType = TickersViewModel.SortType(rawValue: viewModel.sortType.rawValue + 1) ?? .name
        }
    }
}
