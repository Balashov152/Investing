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
    @StateObject var viewModel: TickersViewModel

    var body: some View {
        List {
            Section(header: Text("Total")) {
                MoneyRow(label: "Total RUB",
                         money: .init(currency: .RUB, value: viewModel.totalRUB))
                MoneyRow(label: "Total USD",
                         money: .init(currency: .USD, value: viewModel.totalUSD))
            }

            if !viewModel.results.isEmpty {
                ForEach([InstrumentType.Stock, .Bond, .Etf], id: \.self) { type in
                    Section(header: Text(type.rawValue)) {
                        ForEach(viewModel.results.filter { $0.instrument.type == type }) {
                            commisionCell(insturment: $0.instrument, currency: $0.result)
                        }
                    }
                }
            }
        }
        .navigationTitle("Tickers")
        .onAppear(perform: viewModel.loadOperaions)
    }

    func commisionCell(insturment: Instrument, currency: MoneyAmount) -> some View {
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
}
