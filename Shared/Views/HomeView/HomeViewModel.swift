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
        let type: InstrumentType
        let positions: [PositionView]

        var sectionHeader: String {
            switch type {
            case .Bond, .Stock, .Etf:
                return type.rawValue + "s"
            case .Currency:
                return "Currencies"
            }
        }

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

    enum SortType: Int, Codable {
        case name, price, total, profit

        var text: String {
            "\(self)"
        }
    }
}

class HomeViewModel: EnvironmentCancebleObject, ObservableObject {
    var currencyPairServiceLatest: CurrencyPairServiceLatest { .shared }

    @Published var sortType: SortType {
        willSet {
            env.settings.homeSortType = newValue
        }
    }

    @Published var convertType: ConvertedType

    @Published var sections: [Section] = []
    @Published var convertedTotal: Total?

    @Published var currencies: [CurrencyPosition] = []

    var timer: Timer?

    var positions: [Position] { env.api().positionService.positions }

    var currenciesInPositions: [Currency] {
        positions.map { $0.currency }.unique.sorted(by: >)
    }

    override init(env: Environment = .current) {
        if let currency = env.settings.currency {
            convertType = .currency(currency)
        } else {
            convertType = .original
        }

        sortType = env.settings.homeSortType

        super.init(env: env)
    }

    override func bindings() {
        super.bindings()
        let changeSort = Publishers.CombineLatest($convertType.removeDuplicates(),
                                                  $sortType.removeDuplicates()).handleEvents(receiveOutput: { _ in
            Vibration.selection.vibrate()
        })

        let didChange = Publishers.CombineLatest4(env.api().positionService.$positions.dropFirst(),
                                                  env.api().positionService.$currencies.dropFirst(),
                                                  env.api().operationsService.$operations.dropFirst(),
                                                  changeSort)
            .receive(on: DispatchQueue.global()).share()

        didChange
            .map { positions, currencies, _, currencyType -> HomeViewModel.Total? in
                switch currencyType.0 {
                case let .currency(currency):
                    let totalInProfile = positions.reduce(0) { [unowned self] (result, position) -> Double in
                        result + CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                                money: position.totalInProfile,
                                                                to: currency).value
                    } + currencies.reduce(0) { [unowned self] (result, currencyPosition) -> Double in
                        result + CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                                money: currencyPosition.money,
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

        didChange
            .map { [unowned self] positions, currencies, operations, tuple -> [Section] in
                [InstrumentType.Stock, .Bond, .Etf, .Currency].compactMap { type -> HomeViewModel.Section? in
                    switch type {
                    case .Stock, .Bond, .Etf:
                        let filtered = map(operations: operations, positions: positions, to: tuple.0)
                            .filter { $0.instrumentType == .some(type) }
                            .sorted {
                                switch tuple.1 {
                                case .name:
                                    return $0.name.orEmpty < $1.name.orEmpty
                                case .price:
                                    return $0.averagePositionPriceNow.value > $1.averagePositionPriceNow.value
                                case .profit:
                                    return $0.expectedYield.value > $1.expectedYield.value
                                case .total:
                                    return $0.totalInProfile.value > $1.totalInProfile.value
                                }
                            }

                        if !filtered.isEmpty {
                            return Section(type: type, positions: filtered)
                        }
                        return nil
                    case .Currency:
                        let positions = currencies.map { currencyPos -> PositionView in
                            PositionView(currency: currencyPos,
                                         percentInProfile: percentInProfile(total: currencyPos.balance))
                        }
                        return Section(type: type, positions: positions)
                    }
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.sections, on: self)
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
        env.api().operationsService.getOperations(request: .init(env: env))
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { [unowned self] _ in
            loadPositions()
        })
    }

    private func map(operations: [Operation], positions: [Position], to currencyType: ConvertedType) -> [PositionView] {
        positions.map { position -> PositionView in
            let expectedYield: MoneyAmount
            let averagePositionPrice: MoneyAmount

            if env.settings.adjustedAverage {
                let paymentTotal = operations.paymentTotal(position: position)
                expectedYield = paymentTotal + position.totalInProfile

                let avg = (position.totalInProfile - expectedYield).value / Double(position.lots)
                averagePositionPrice = MoneyAmount(currency: position.currency, value: avg)

            } else {
                expectedYield = position.expectedYield
                averagePositionPrice = position.averagePositionPrice
            }

            switch currencyType {
            case let .currency(currency):
                let avgNow = convert(money: position.averagePositionPriceNow, to: currency)
                let totalInProfile = (avgNow.value * Double(position.lots)).addCurrency(currency)

                return PositionView(position: position,
                                    percentInProfile: percentInProfile(total: totalInProfile.value),
                                    expectedYield: convert(money: expectedYield, to: currency),
                                    averagePositionPrice: convert(money: averagePositionPrice, to: currency),
                                    averagePositionPriceNow: avgNow)

            case .original:
                return PositionView(position: position,
                                    percentInProfile: percentInProfile(total: position.totalInProfile.value),
                                    expectedYield: expectedYield,
                                    averagePositionPrice: averagePositionPrice,
                                    averagePositionPriceNow: position.averagePositionPriceNow)
            }
        }
    }

    private func percentInProfile(total: Double) -> Double {
        guard let convertedTotal = convertedTotal else { return 0 }
        return (total / convertedTotal.totalInProfile.value) * 100
    }

    private func convert(money: MoneyAmount, to currency: Currency) -> MoneyAmount {
        money.convert(to: currency, pair: currencyPairServiceLatest.latest)
    }
}

extension MoneyAmount {
    func convert(to currency: Currency, pair: CurrencyPair?) -> MoneyAmount {
        guard let pair = pair else { return self }
        return CurrencyConvertManager.convert(currencyPair: pair, money: self, to: currency)
    }
}

extension Collection where Element == Operation {
    func operations(position: Position) -> [Operation] {
        filter { $0.figi == position.figi }
    }

    func paymentTotal(position: Position, currency: Currency? = nil) -> MoneyAmount {
        operations(position: position).currencySum(to: currency ?? position.currency)
    }
}
