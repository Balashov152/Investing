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

        var currencyValue: Currency? {
            if case let .currency(currency) = self {
                return currency
            }
            return nil
        }

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
        let blocked: MoneyAmount?
        let expectedProfile: MoneyAmount

        var currency: Currency {
            expectedProfile.currency
        }

        var percent: Double {
            (expectedProfile / totalInProfile).value * 100
        }
    }

    enum SortType: Int, Codable {
        case name, price, position, profit

        var text: String {
            "\(self)".capitalized
        }

        var systemImageName: String {
            switch self {
            case .profit, .price, .position:
                return "arrow.up"
            case .name:
                return "arrow.down"
            }
        }
    }

    struct ConvertSortModel {
        let convert: ConvertedType
        let sort: SortType
    }

    struct Sources {
        let positions: [Position]
        let currencies: [CurrencyPosition]
        let operations: [Operation]
    }
}

extension Position {
    func blocked(settings: Settings) -> MoneyAmount? {
        settings.blockedPosition[ticker]
    }
}

class HomeViewModel: EnvironmentCancebleObject, ObservableObject {
    var currencyPairServiceLatest: CurrencyPairServiceLatest { .shared }
    // Input

    @Published var sortType: SortType {
        willSet {
            env.settings.homeSortType = newValue
        }
    }

    @Published var convertType: ConvertedType {
        willSet {
            switch newValue {
            case .original:
                env.settings.currency = nil
            case let .currency(currency):
                env.settings.currency = currency
            }
        }
    }

    // Output
    @Published var sections: [Section] = []
    @Published var currencies: [CurrencyPosition] = []

    var timer: Timer?
    var convertedTotal: Total?

    var positions: [Position] {
        env.api().positionService.positions
    }

    var currenciesInPositions: [Currency] {
        positions.map { $0.currency }.unique.sorted(by: >)
    }

    func currencyOperation(currency: Currency) -> [Operation] {
        env.operationsService.operations
            .filter(types: [.PayIn, .PayOut],
                    or: { $0.instrumentType == .some(.Currency) })
            .filter { $0.opCurrency == currency }
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
        let changeConvertSort = Publishers.CombineLatest($convertType.removeDuplicates(),
                                                         $sortType.removeDuplicates())
            .map { ConvertSortModel(convert: $0, sort: $1) }

        let changeSourses = Publishers.CombineLatest3(env.api().positionService.$positions.dropFirst(),
                                                      env.api().positionService.$currencies.dropFirst(),
                                                      env.api().operationsService.$operations.dropFirst())
            .map { Sources(positions: $0, currencies: $1, operations: $2) }

        let didChangeView = Publishers
            .CombineLatest(changeConvertSort, changeSourses)
            .receive(on: DispatchQueue.global()).share()

        changeConvertSort.dropFirst().sink(receiveValue: { _ in
            Vibration.selection.vibrate()
        }).store(in: &cancellables)

        didChangeView.sink(receiveValue: { [unowned self] convertSortModel, sourses in
            changeView(convertSortModel: convertSortModel, sources: sourses)
        }).store(in: &cancellables)

//        startTimer()
    }

    public func loadPositions() {
        env.api().positionService.getPositions()
        env.api().positionService.getCurrences()
        env.api().operationsService.getOperations(request: .init(env: env))
    }

    private func changeView(convertSortModel: ConvertSortModel, sources: Sources) {
        let total = convertTotal(sources: sources, currency: convertSortModel.convert.currencyValue ?? .USD)
        convertedTotal = total

        let sections = setupSections(convertSortModel: convertSortModel, sources: sources)
        DispatchQueue.main.async {
            self.sections = sections
        }
    }

    private func convertTotal(sources: Sources, currency: Currency) -> Total {
        let positions = sources.positions.filter { $0.instrumentType != .Currency }
        let currencies = sources.currencies

        let totalInProfile = positions.reduce(0) { (result, position) -> Double in
            result + CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                    money: position.totalInProfile,
                                                    to: currency).value
        }.addCurrency(currency)

        let currenciesInProfile = currencies.reduce(0) { (result, currencyPosition) -> Double in
            result + CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                    money: currencyPosition.money,
                                                    to: currency).value
        }.addCurrency(currency)

        var expectedProfile: MoneyAmount

        if env.settings.adjustedTotal {
            let operations = sources.operations.filter { $0.instrumentType != .some(.Currency) }
            let sell = operations.totalSell(to: currency)
            let buy = operations.totalBuy(to: currency)
//            debugPrint("sell", sell.value, "buy", buy.value)
            expectedProfile = sell + buy + totalInProfile

        } else {
            expectedProfile = positions.reduce(0) { (result, position) -> Double in
                result + CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                        money: position.expectedYield,
                                                        to: currency).value
            }.addCurrency(currency)
        }

        let blocked = positions.reduce(nil) { (result, position) -> Double? in
            if let blocked = position.blocked(settings: env.settings) {
                return (result ?? 0) + CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                                      money: blocked,
                                                                      to: currency).value
            }
            return result
        }?.addCurrency(currency)

        var total = totalInProfile + currenciesInProfile
        if env.settings.minusDebt, let blocked = blocked {
            total = total - blocked
        }

        return Total(totalInProfile: total,
                     blocked: blocked, expectedProfile: expectedProfile)
    }

    private func setupSections(convertSortModel: ConvertSortModel, sources: Sources) -> [Section] {
        [InstrumentType.Stock, .Bond, .Etf, .Currency].compactMap { type -> HomeViewModel.Section? in
            let positions = sources.positions.filter { $0.instrumentType == type }

            switch type {
            case .Stock, .Bond, .Etf:
                let filtered = map(operations: sources.operations, positions: positions,
                                   to: convertSortModel.convert).sorted {
                    switch sortType {
                    case .name:
                        return $0.name.orEmpty < $1.name.orEmpty
                    case .price:
                        return $0.averagePositionPriceNow.value > $1.averagePositionPriceNow.value
                    case .profit:
                        return $0.expectedYield.value > $1.expectedYield.value
                    case .position:
                        return $0.totalInProfile.value > $1.totalInProfile.value
                    }
                }

                if !filtered.isEmpty {
                    return Section(type: type, positions: filtered)
                }
                return nil
            case .Currency:
                let positions = sources.currencies.map { currencyPos -> PositionView in
                    PositionView(currency: currencyPos,
                                 percentInProfile: percentInProfile(total: currencyPos.balance))
                }
                return Section(type: type, positions: positions)
            }
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { [unowned self] _ in
            loadPositions()
        })
    }

    private func map(operations: [Operation], positions: [Position], to currencyType: ConvertedType) -> [PositionView]
    {
        return positions.map { position -> PositionView in
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

                var blocked: MoneyAmount?
                if let saveBlocked = env.settings.blockedPosition[position.ticker] {
                    blocked = convert(money: saveBlocked, to: currency)
                }

                return PositionView(position: position,
                                    percentInProfile: percentInProfile(total: totalInProfile.value),
                                    blocked: blocked,
                                    expectedYield: convert(money: expectedYield, to: currency),
                                    averagePositionPrice: convert(money: averagePositionPrice, to: currency),
                                    averagePositionPriceNow: avgNow)

            case .original:
                return PositionView(position: position,
                                    percentInProfile: percentInProfile(total: position.totalInProfile.value),
                                    blocked: env.settings.blockedPosition[position.ticker],
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

extension Collection where Element == Operation {
    func operations(position: Position) -> [Operation] {
        filter { $0.figi == position.figi }
    }

    func paymentTotal(position: Position, currency: Currency? = nil) -> MoneyAmount {
        operations(position: position).currencySum(to: currency ?? position.currency)
    }
}
