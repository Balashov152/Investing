//
//  PorfolioViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 28.02.2022.
//

import Combine
import InvestModels
import SwiftUI

class PorfolioViewModel: CancebleObject, ObservableObject {
    @Published var dataSource: [PorfolioSectionViewModel] = []
    @Published var sortType: SortType = .inProfile
    @Published var isPresentAccounts: Bool = false

    private let refreshSubject = CurrentValueSubject<Void, Never>(())
    private let realmStorage: RealmStoraging

    let moduleFactory: ModuleFactoring

    private var updateViewCancellable: AnyCancellable?

    init(
        realmStorage: RealmStoraging,
        moduleFactory: ModuleFactoring
    ) {
        self.realmStorage = realmStorage
        self.moduleFactory = moduleFactory
    }

    public func refresh() {
        refreshSubject.send()
    }
}

extension PorfolioViewModel: ViewLifeCycleOperator {
    func onAppear() {
        setupUpdateContent()
    }
}

extension PorfolioViewModel {
    func setupUpdateContent() {
        guard updateViewCancellable == nil else {
            return
        }

        updateViewCancellable = Publishers.CombineLatest($sortType, refreshSubject)
            .receive(on: DispatchQueue.global())
            .map { [unowned self] sortType, _ -> [PorfolioSectionViewModel] in
                let accounts = realmStorage.selectedAccounts()

                return accounts.map {
                    map(account: $0, sortType: sortType)
                }
                .sorted(by: { $0.id > $1.id })
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.dataSource, on: self)
    }

    func map(account: BrokerAccount, sortType: SortType) -> PorfolioSectionViewModel {
        let uniqueInstrument = Set(account.operations.compactMap { $0.figi })

        var positions = uniqueInstrument.compactMap { figi -> PorfolioPositionViewModel? in
            self.map(account: account, figi: figi)
        }

        soted(positions: &positions, sortType: sortType)

        let uiCurrencies = Set(positions.map { $0.uiCurrency }).sorted()

        let results: [MoneyAmount] = uiCurrencies.map { currency in
            let amount = positions
                .filter { $0.uiCurrency == currency }
                .reduce(0) { $0 + $1.result.value }

            return MoneyAmount(uiCurrency: currency, value: amount)
        }

        return PorfolioSectionViewModel(
            accountName: account.name,
            operations: positions,
            results: results
        )
    }

    func map(account: BrokerAccount, figi: String) -> PorfolioPositionViewModel? {
        guard let instrument = realmStorage.share(figi: figi) else {
            return nil
        }

        let instrumentInProfile = account.portfolio?.positions.first(where: { $0.figi == figi })
        let allOperations = account.operations.filter { $0.figi == figi }

        var resultAmount: Double = allOperations.reduce(0) { result, operation in
            result + (operation.payment?.price ?? 0)
        }

        let average = average(
            for: instrumentInProfile,
            currency: instrument.currency,
            resultAmount: &resultAmount
        )

        var inPortfolio: PorfolioPositionViewModel.InPortfolio?

        if let average = average,
           let quantity = instrumentInProfile?.quantity
        {
            inPortfolio = PorfolioPositionViewModel.InPortfolio(
                quantity: quantity.price,
                price: average
            )
        }

        let result = MoneyAmount(currency: instrument.currency, value: resultAmount)

        return PorfolioPositionViewModel(
            figi: figi,
            name: instrument.name ?? "",
            ticker: instrument.ticker ?? "",
            isin: instrument.isin,
            uiCurrency: UICurrency(currency: instrument.currency) ?? .usd,
            instrumentType: .Stock,
            result: result,
            inPortfolio: inPortfolio,
            average: average
        )
    }

    func soted(positions: inout [PorfolioPositionViewModel], sortType: SortType) {
        switch sortType {
        case .name:
            positions.sort { $0.name < $1.name }
        case .inProfile:

            let inPortfolio = positions
                .filter { $0.inPortfolio != nil }
                .sorted { $0.name < $1.name }

            let notPortfolio = positions
                .filter { $0.inPortfolio == nil }
                .sorted { $0.name < $1.name }

            positions = inPortfolio + notPortfolio

        case .profit:
            let availableCurrency = Set(positions.map { $0.uiCurrency }).sorted()

            positions = availableCurrency.sorted().reduce([]) { result, uiCurrency in
                result + positions
                    .filter { $0.uiCurrency == uiCurrency }
                    .sorted { $0.result.value > $1.result.value }
            }
        }
    }

    func average(
        for instrumentInProfile: PortfolioPosition?,
        currency: Price.Currency,
        resultAmount: inout Double
    ) -> MoneyAmount? {
        guard let quantity = instrumentInProfile?.quantity,
              let positionPrice = instrumentInProfile?.inPortfolioPrice
        else {
            return nil
        }

        resultAmount += positionPrice.value

        let averageAmount: Double = {
            if resultAmount > 0 {
                return resultAmount / quantity.price
            } else {
                return (abs(resultAmount) + positionPrice.value) / quantity.price
            }
        }()

        return MoneyAmount(currency: currency, value: averageAmount)
    }
}

extension PorfolioViewModel: AccountsListOutput {
    func accountsDidSelectAccounts() {
        isPresentAccounts = false
        refresh()
    }
}

struct PorfolioSectionViewModel: Hashable, Identifiable {
    let accountName: String
    let operations: [PorfolioPositionViewModel]
    let results: [MoneyAmount]

    func hash(into hasher: inout Hasher) {
        hasher.combine(accountName)
    }
}

extension PorfolioViewModel {
    enum SortType: Int {
        case inProfile, profit, name
        var localize: String {
            switch self {
            case .name:
                return "По имени"
            case .inProfile:
                return "В портфеле"
            case .profit:
                return "Прибыль"
            }
        }
    }
}
