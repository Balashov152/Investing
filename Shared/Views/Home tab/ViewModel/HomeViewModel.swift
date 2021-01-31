//
//  HomeViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 15.01.2021.
//

import Combine
import Foundation
import InvestModels

extension HomeViewModel {
    struct Section: Hashable, Identifiable {
        var id: Int { hashValue }

        let type: InstrumentType
        let positions: [PositionView]

        var currencies: [Currency] {
            positions.map { $0.currency }.unique
        }

        func totalInProfile(currency: Currency) -> Double {
            positions.filter { $0.currency == currency }
                .reduce(0) { $0 + $1.totalInProfile.value }
        }

        func totalChanged(currency: Currency) -> Double {
            positions.filter { $0.currency == currency }
                .reduce(0) { $0 + $1.totalInProfile.value - $1.totalBuyPayment.value }
        }

        func percentChanged(currency: Currency) -> Double {
            (totalChanged(currency: currency) / totalInProfile(currency: currency)) * 100
        }
    }

    enum ConvertedType: Equatable {
        case original
        case currency(Currency)

        var localize: String {
            switch self {
            case let .currency(currency):
                return currency.rawValue
            case .original:
                return "" // "orignal"
            }
        }
    }

    struct Total: TotalViewModeble {
        let totalInProfile: MoneyAmount
        let expectedProfile: MoneyAmount

        var percent: Double {
            (expectedProfile / totalInProfile).value * 100
        }
    }
}

class HomeViewModel: EnvironmentCancebleObject, ObservableObject {
    var currencyPairServiceLatest: CurrencyPairServiceLatest { .shared }

    @Published var convertType: ConvertedType

    @Published var sections: [Section] = []
    @Published var convertedTotal: Total?

    @Published var currencies: [CurrencyPosition] = []

    var positions: [Position] { env.api().positionService.positions }

    override init(env: Environment = .current) {
        if let currency = env.settings.currency {
            convertType = .currency(currency)
        } else {
            convertType = .original
        }

        super.init(env: env)
    }

    var timer: Timer?

    var currenciesInPositions: [Currency] {
        positions.map { $0.currency }.unique.sorted(by: >)
    }

    override func bindings() {
        super.bindings()
        let didChange = Publishers.CombineLatest3(env.api().positionService.$positions.dropFirst(),
                                                  env.api().positionService.$currencies.dropFirst(),
                                                  $convertType.removeDuplicates().handleEvents(receiveOutput: { _ in
                                                      // TODO: Add vibrate
                                                  }))
            .receive(on: DispatchQueue.global()).share()

        didChange
            .map { [unowned self] positions, currencies, currencyType -> [Section] in
                InstrumentType.allCases.compactMap { type -> HomeViewModel.Section? in
                    switch type {
                    case .Stock, .Bond, .Etf:
                        let filtered = map(positions: positions, to: currencyType)
                            .filter { $0.instrumentType == .some(type) }
                            .sorted { $0.name.orEmpty < $1.name.orEmpty }

                        if !filtered.isEmpty {
                            return Section(type: type, positions: filtered)
                        }
                        return nil
                    case .Currency:
                        let positions = currencies.map { currencyPos -> PositionView in
                            PositionView(currency: currencyPos)
                        }
                        return Section(type: type, positions: positions)
                    }
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.sections, on: self)
            .store(in: &cancellables)

        didChange
            .map { positions, _, currencyType -> HomeViewModel.Total? in
                switch currencyType {
                case let .currency(currency):
                    let totalInProfile = positions.reduce(0) { [unowned self] (result, position) -> Double in
                        result + CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                                money: position.totalInProfile,
                                                                to: currency).value
                    }

                    let expectedProfile = positions.reduce(0) { [unowned self] (result, position) -> Double in
                        result + CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                                money: position.expectedYield,
                                                                to: currency).value
                    }

                    return Total(totalInProfile: totalInProfile.addCurrency(currency),
                                 expectedProfile: expectedProfile.addCurrency(currency))
                case .original:
                    return nil
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.convertedTotal, on: self)
            .store(in: &cancellables)

//        startTimer()

        $convertType.dropFirst().sink(receiveValue: { value in
            switch value {
            case .original:
                Settings.shared.currency = nil
            case let .currency(currency):
                Settings.shared.currency = currency
            }
        }).store(in: &cancellables)
    }

    public func loadPositions() {
        env.api().positionService.getPositions()
        env.api().positionService.getCurrences()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { [unowned self] _ in
            loadPositions()
        })
    }

    private func map(positions: [Position], to currencyType: ConvertedType) -> [PositionView] {
        switch currencyType {
        case let .currency(currency):
            return positions.map { position -> PositionView in
                PositionView(position: position,
                             expectedYield: CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                                           money: position.expectedYield,
                                                                           to: currency),
                             averagePositionPrice: CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                                                  money: position.averagePositionPrice,
                                                                                  to: currency))
            }
        case .original:
            return positions.map { position -> PositionView in
                PositionView(position: position)
            }
        }
    }
}