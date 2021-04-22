//
//  TickersViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Combine
import InvestModels
import SwiftUI

class TickersViewModel: EnvironmentCancebleObject, ObservableObject {
    var latest: CurrencyPair? { env.api().currencyPairLatest().latest }
    @Published var results: [InstrumentResult] = []

    @Published var totalRUB: Double = 0
    @Published var totalUSD: Double = 0

    @Published var sortType: SortType = .name

    public func loadOperaions() {
        env.api().operationsService.getOperations(request: .init(env: env))
        env.api().positionService().getPositions()
    }

    override func bindings() {
        Publishers.CombineLatest3(env.api().operationsService.$operations,
                                  env.api().positionService().$positions.dropFirst(),
                                  $sortType)
            .receive(on: DispatchQueue.global())
            .map { [unowned self] operations, positions, sortType in
                mapToResults(operations: operations, positions: positions, sortType: sortType)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.results, on: self)
            .store(in: &cancellables)

        $results
            .map {
                $0.filter {
                    $0.instrument.currency == .USD && $0.instrument.type != .Currency
                }.map { $0.result }.sum
            }
            .assign(to: \.totalUSD, on: self)
            .store(in: &cancellables)

        $results
            .map { $0.filter {
                $0.instrument.currency == .RUB && $0.instrument.type != .Currency
            }.map { $0.result }.sum
            }
            .assign(to: \.totalRUB, on: self)
            .store(in: &cancellables)
    }

    private func mapToResults(operations: [Operation], positions: [Position], sortType: SortType) -> [InstrumentResult] {
        let uniqTickers = Set(operations.compactMap { $0.instrument }.filter { $0.type != .Currency })
        return uniqTickers.map { ticker -> InstrumentResult in

            let currency = ticker.currency
            let nowInProfile = positions.first(where: { $0.figi == ticker.figi })?.totalInProfile

            var sumOperation = operations
                .filter { $0.instrument?.figi == ticker.figi }
                .currencySum(to: currency)

            if let nowInProfile = nowInProfile {
                assert(currency == nowInProfile.currency)

                sumOperation = sumOperation + nowInProfile
            }

            let result = InstrumentResult(instrument: ticker, result: sumOperation, inProfile: nowInProfile != nil)
            return result
        }.sorted(by: {
            switch sortType {
            case .name:
                return $0.instrument.name < $1.instrument.name
            case .inProfile:
                return $0.inProfile.value > $1.inProfile.value
            case .profit:
                return $0.result.convert(to: .USD, pair: latest).value >
                    $1.result.convert(to: .USD, pair: latest).value
            }
        })
    }
}

extension TickersViewModel {
    struct InstrumentResult: Hashable, Identifiable {
        let instrument: Instrument
        let result: MoneyAmount
        let inProfile: Bool
    }

    enum SortType: Int {
        case name, inProfile, profit
        var localize: String {
            return "\(self)"
        }
    }
}

extension Bool {
    var value: Int { self ? 1 : 0 }
}
