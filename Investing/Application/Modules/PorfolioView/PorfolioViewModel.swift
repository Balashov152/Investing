//
//  PorfolioViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 28.02.2022.
//

import Combine
import InvestModels
import SwiftUI

protocol PorfolioViewOutput: AnyObject {
    func didRequestRefresh(completion: @escaping () -> Void)
}

class PorfolioViewModel: CancebleObject, ObservableObject {
    @Published var totals: [MoneyAmount] = []
    @Published var dataSource: [PorfolioSectionViewModel] = []
    @Published var sortType: SortType = .inProfile
    @Published var isPresentAccounts: Bool = false
    
    private let refreshSubject = CurrentValueSubject<Void, Never>(())

    private weak var output: PorfolioViewOutput?
    private let realmStorage: RealmStoraging
    private let calculatorManager: CalculatorManager

    let moduleFactory: ModuleFactoring

    private var updateViewCancellable: AnyCancellable?

    init(
        output: PorfolioViewOutput,
        realmStorage: RealmStoraging,
        calculatorManager: CalculatorManager,
        moduleFactory: ModuleFactoring
    ) {
        self.output = output
        self.realmStorage = realmStorage
        self.calculatorManager = calculatorManager
        self.moduleFactory = moduleFactory
    }

    public func refresh() async {
        await withCheckedContinuation { configuration in
            output?.didRequestRefresh() { [weak self] in
                configuration.resume()
                DispatchQueue.main.async { [weak self] in
                    self?.refreshSubject.send()
                }
            }
        }
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
            .receive(queue: .global())
            .print("setupUpdateContent")
            .map { [unowned self] sortType, _ -> [PorfolioSectionViewModel] in
                let accounts = realmStorage.selectedAccounts()

                return accounts.map {
                    map(account: $0, sortType: sortType)
                }
                .sorted(by: { $0.account.name < $1.account.name })
            }
            .receive(queue: DispatchQueue.main)
            .assign(to: \.dataSource, on: self)

        $dataSource
            .receive(queue: .global())
            .map { models in
                let results = models.reduce([]) { $0 + $1.results }

                let uniqCurrencies = results.map { $0.currency }.unique.sorted()

                let totals = uniqCurrencies.map { currency -> MoneyAmount in
                    MoneyAmount(
                        currency: currency,
                        value: results.filter { $0.currency == currency }.sum
                    )
                }

                return totals
            }
            .receive(queue: DispatchQueue.main)
            .assign(to: \.totals, on: self)
            .store(in: &cancellables)
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
            account: account,
            operations: positions,
            results: results
        )
    }

    func map(account: BrokerAccount, figi: String) -> PorfolioPositionViewModel? {
        guard let instrument = realmStorage.share(figi: figi),
              let (result, average) = calculatorManager.calculateResult(on: figi, in: account)
        else {
            return nil
        }

        var inPortfolio: PorfolioPositionViewModel.InPortfolio?
        let instrumentInProfile = account.portfolio?.positions.first(where: { $0.figi == figi })

        if let average = average,
           let quantity = instrumentInProfile?.quantity
        {
            inPortfolio = PorfolioPositionViewModel.InPortfolio(
                quantity: quantity.price,
                price: average
            )
        }

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
}

extension PorfolioViewModel: AccountsListOutput {
    func accountsDidSelectAccounts() {
        isPresentAccounts = false
        DispatchQueue.main.async { [weak self] in
            self?.refreshSubject.send()
        }
    }
}

struct PorfolioSectionViewModel: Hashable, Identifiable {
    var id: Int { hashValue }
    
    let account: BrokerAccount
    let operations: [PorfolioPositionViewModel]
    let results: [MoneyAmount]

    func hash(into hasher: inout Hasher) {
        hasher.combine(account.id)
        hasher.combine(results)
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
