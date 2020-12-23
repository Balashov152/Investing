//
//  TickersView.swift
//  Investing
//
//  Created by Sergey Balashov on 19.12.2020.
//

import Combine
import InvestModels
import SwiftUI

struct ResultTickerMoney: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(instrument)
        hasher.combine(money)
    }

    let instrument: Instrument
    let money: MoneyAmount
}

class TickersViewModel: EnvironmentCancebleObject, ObservableObject {
    @Published var results: [ResultTickerMoney] = []

    @Published var totalRUB: Double = 0
    @Published var totalUSD: Double = 0

    override init(env: Environment = .current) {
        super.init(env: env)
        bindings()
    }

    public func loadOperaions() {
        env.operationsService.getOperations(request: .init(env: env))
    }

    override func bindings() {
        env.operationsService.$operations
            .receive(on: DispatchQueue.global())
            .map { [unowned self] operations in
                mapToResults(operations: operations)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.results, on: self)
            .store(in: &cancellables)

        $results
            .map { $0.filter { $0.instrument.currency == .USD }.map { $0.money }.sum }
            .assign(to: \.totalUSD, on: self)
            .store(in: &cancellables)

        $results
            .map { $0.filter { $0.instrument.currency == .RUB }.map { $0.money }.sum }
            .assign(to: \.totalRUB, on: self)
            .store(in: &cancellables)
    }

    private func mapToResults(operations: [Operation]) -> [ResultTickerMoney] {
        let uniqTickers = Array(Set(operations.compactMap { $0.instument }))
        return uniqTickers.map { ticker -> ResultTickerMoney in
            let nowInProfile: Double = 0 // TODO: addPositions mainViewModel.positions.first(where: { $0.figi == ticker.figi })?.totalInProfile ?? 0
            let allOperationsForTicker = operations.filter { $0.instument == ticker }
            let sumOperation = allOperationsForTicker.sum + nowInProfile
            return ResultTickerMoney(instrument: ticker, money: MoneyAmount(currency: allOperationsForTicker.first?.currency ?? .TRY,
                                                                            value: sumOperation))
        }.sorted(by: { $0.instrument.name.orEmpty < $1.instrument.name.orEmpty })
    }
}

struct TickersView: View {
    @StateObject var viewModel: TickersViewModel

    var body: some View {
        List {
            Section(header: Text("Total")) {
                totalCell(label: "Total RUB", value: viewModel.totalRUB)
                totalCell(label: "Total USD", value: viewModel.totalUSD)
            }

            Section(header: Text("Tickers")) {
                ForEach(viewModel.results, id: \.self) {
                    commisionCell(insturment: $0.instrument, currency: $0.money)
                }
            }
        }.navigationTitle("Tickers")
            .onAppear(perform: viewModel.loadOperaions)
    }

    func totalCell(label: String, value: Double) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value.string(f: ".2"))
                .foregroundColor(value > 0 ? .green : .red)
        }
    }

    func commisionCell(insturment: Instrument, currency: MoneyAmount) -> some View {
        HStack {
            VStack(alignment: .leading) {
                if let name = insturment.name {
                    Text(name)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                }
                HStack {
                    if let type = insturment.type {
                        Text(type.rawValue).font(.system(size: 14))
                    }

                    if let ticker = insturment.ticker {
                        Text(ticker).font(.system(size: 14))
                    }
                }
            }
            Spacer()
            Text(currency.value.string(f: ".2") + " " + currency.currency.rawValue)
                .foregroundColor(Color.currency(value: currency.value))
        }
    }
}
