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
    @Published var results: [InstrumentResult] = []

    @Published var totalRUB: Double = 0
    @Published var totalUSD: Double = 0

    @Published var sortType: SortType = .name

    public func loadOperaions() {
        env.api().operationsService.getOperations(request: .init(env: env))
        env.api().positionService.getPositions()
    }

    override func bindings() {
        Publishers.CombineLatest3(env.api().operationsService.$operations,
                                  env.api().positionService.$positions.dropFirst(),
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
        let uniqTickers = Array(Set(operations.compactMap { $0.instrument }.filter { $0.type != .Currency }))
        return uniqTickers.map { ticker -> InstrumentResult in
            let nowInProfile: Double = positions.first(where: { $0.figi == ticker.figi })?.totalInProfile.value ?? 0
            let allOperationsForTicker = operations.filter { $0.instrument?.figi == ticker.figi }
            let sumOperation = allOperationsForTicker.sum + nowInProfile
            return InstrumentResult(instrument: ticker,
                                    result: MoneyAmount(currency: allOperationsForTicker.first?.currency ?? .USD, value: sumOperation),
                                    inProfile: nowInProfile > 0)
        }.sorted(by: {
            switch sortType {
            case .name:
                return $0.instrument.name < $1.instrument.name
            case .inProfile:
                return $0.inProfile.hashValue < $1.inProfile.hashValue
            case .profit:
                return $0.result.value > $1.result.value
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
