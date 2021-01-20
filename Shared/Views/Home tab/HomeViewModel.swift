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

        func sum(currency: Currency) -> Double {
            positions.filter { $0.currency == currency }
                .reduce(0) { $0 + $1.totalInProfile.value - $1.totalBuyPayment.value }
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
}

class HomeViewModel: EnvironmentCancebleObject, ObservableObject {
    let currencyPairServiceLatest: CurrencyPairServiceLatest

    @Published var convertType: ConvertedType

    @Published var sections: [Section] = []
    @Published var convertedTotal: MoneyAmount?

    @Published var positions: [Position] = []
    @Published var currencies: [CurrencyPosition] = []

    override init(env: Environment = .current) {
        currencyPairServiceLatest = CurrencyPairServiceLatest(env: env)

        if let currency = env.settings().currency {
            convertType = .currency(currency)
        } else {
            convertType = .original
        }

        super.init(env: env)
    }

    var timer: Timer?

    override func bindings() {
        super.bindings()
        Publishers.CombineLatest($positions.dropFirst(), $convertType.removeDuplicates())
            .receive(on: DispatchQueue.global())
            .map { [unowned self] positions, currencyType -> [PositionView] in
                self.map(positions: positions, to: currencyType)
            }
            .map { positions -> [Section] in
                [InstrumentType.Stock, .Bond, .Etf].compactMap { type -> Section? in
                    let filtered = positions
                        .filter { $0.instrumentType == .some(type) }
                        .sorted { $0.name.orEmpty < $1.name.orEmpty }
                    if !filtered.isEmpty {
                        return Section(type: type, positions: filtered)
                    }
                    return nil
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.sections, on: self)
            .store(in: &cancellables)

        Publishers.CombineLatest($positions.dropFirst(), $convertType.removeDuplicates())
            .receive(on: DispatchQueue.global())
            .map { positions, currencyType -> MoneyAmount? in
                switch currencyType {
                case let .currency(currency):
                    let sum = positions.reduce(0) { [unowned self] (result, position) -> Double in
                        result + CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                                money: position.totalInProfile,
                                                                to: currency).value
                    }
                    return MoneyAmount(currency: currency, value: sum)
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
            .replaceError(with: [])
            .assign(to: \.positions, on: self)
            .store(in: &cancellables)

        env.api().positionService.getCurrences()
            .replaceError(with: [])
            .assign(to: \.currencies, on: self)
            .store(in: &cancellables)
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
