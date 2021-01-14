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
    let instrument: Instrument
    let money: MoneyAmount
}

class TickersViewModel: EnvironmentCancebleObject, ObservableObject {
    @Published var results: [ResultTickerMoney] = []

    @Published var positions: [Position] = []

    @Published var totalRUB: Double = 0
    @Published var totalUSD: Double = 0

    override init(env: Environment = .current) {
        super.init(env: env)
        bindings()
    }

    public func loadOperaions() {
        env.operationsService.getOperations(request: .init(env: env))

        env.api().positionService.getPositions()
            .replaceError(with: [])
            .assign(to: \.positions, on: self)
            .store(in: &cancellables)
    }

    override func bindings() {
        Publishers.CombineLatest(env.operationsService.$operations, $positions)
            .receive(on: DispatchQueue.global())
            .map { [unowned self] operations, positions in
                mapToResults(operations: operations, positions: positions)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.results, on: self)
            .store(in: &cancellables)

        $results
            .map {
                $0.filter {
                    $0.instrument.currency == .USD && $0.instrument.type != .Currency
                }.map { $0.money }.sum
            }
            .assign(to: \.totalUSD, on: self)
            .store(in: &cancellables)

        $results
            .map { $0.filter {
                $0.instrument.currency == .RUB && $0.instrument.type != .Currency
            }.map { $0.money }.sum
            }
            .assign(to: \.totalRUB, on: self)
            .store(in: &cancellables)
    }

    private func mapToResults(operations: [Operation], positions: [Position]) -> [ResultTickerMoney] {
        let uniqTickers = Array(Set(operations.compactMap { $0.instrument }.filter { $0.type != .Currency }))
        return uniqTickers.map { ticker -> ResultTickerMoney in
            let nowInProfile: Double = positions.first(where: { $0.figi == ticker.figi })?.totalInProfile.value ?? 0
            let allOperationsForTicker = operations.filter { $0.instrument?.figi == ticker.figi }
            let sumOperation = allOperationsForTicker.sum + nowInProfile
            return ResultTickerMoney(instrument: ticker,
                                     money: MoneyAmount(currency: allOperationsForTicker.first?.currency ?? .USD, value: sumOperation))
        }.sorted(by: { $0.instrument.name < $1.instrument.name })
    }
}

struct TickersView: View {
    @StateObject var viewModel: TickersViewModel

    var body: some View {
        List {
            Section(header: Text("Total")) {
                totalCell(label: "Total RUB",
                          currency: .init(currency: .RUB, value: viewModel.totalRUB))
                totalCell(label: "Total USD",
                          currency: .init(currency: .USD, value: viewModel.totalUSD))
            }

            if !viewModel.results.isEmpty {
                ForEach([InstrumentType.Stock, .Bond, .Etf], id: \.self) { type in
                    Section(header: Text(type.rawValue)) {
                        ForEach(viewModel.results.filter { $0.instrument.type == type }, id: \.self) {
                            commisionCell(insturment: $0.instrument, currency: $0.money)
                        }
                    }
                }
            }
        }.navigationTitle("Tickers")
            .onAppear(perform: viewModel.loadOperaions)
    }

    func totalCell(label: String, currency: MoneyAmount) -> some View {
        HStack {
            Text(label)
            Spacer()
            MoneyText(money: currency)
        }
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

struct CurrencyText: View {
    let money: MoneyAmount

    var body: some View {
        Text(money.value.formattedCurrency(locale: money.currency.locale))
    }
}

struct MoneyText: View {
    let money: MoneyAmount

    var body: some View {
        Text(money.value.formattedCurrency(locale: money.currency.locale))
            .foregroundColor(Color.currency(value: money.value))
    }
}
