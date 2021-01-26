//
//  TickersViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Combine
import InvestModels
import SwiftUI

extension TickersViewModel {
    struct InstrumentResult: Hashable, Identifiable {
        let instrument: Instrument
        let result: MoneyAmount
    }
}

class TickersViewModel: EnvironmentCancebleObject, ObservableObject {
    @Published var results: [InstrumentResult] = []

    @Published var positions: [Position] = []

    @Published var totalRUB: Double = 0
    @Published var totalUSD: Double = 0

    override init(env: Environment = .current) {
        super.init(env: env)
        bindings()
    }

    public func loadOperaions() {
        env.api().operationsService
            .getOperations(request: .init(env: env))

        env.api().positionService.getPositions()
            .replaceError(with: [])
            .assign(to: \.positions, on: self)
            .store(in: &cancellables)
    }

    override func bindings() {
        Publishers.CombineLatest(env.operationsService.$operations, $positions.dropFirst())
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

    private func mapToResults(operations: [Operation], positions: [Position]) -> [InstrumentResult] {
        let uniqTickers = Array(Set(operations.compactMap { $0.instrument }.filter { $0.type != .Currency }))
        return uniqTickers.map { ticker -> InstrumentResult in
            let nowInProfile: Double = positions.first(where: { $0.figi == ticker.figi })?.totalInProfile.value ?? 0
            let allOperationsForTicker = operations.filter { $0.instrument?.figi == ticker.figi }
            let sumOperation = allOperationsForTicker.sum + nowInProfile
            return InstrumentResult(instrument: ticker,
                                    result: MoneyAmount(currency: allOperationsForTicker.first?.currency ?? .USD, value: sumOperation))
        }.sorted(by: { $0.instrument.name < $1.instrument.name })
    }
}
