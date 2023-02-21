//
//  PorfolioViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 28.02.2022.
//

import Combine
import InvestModels
import SwiftUI
import InvestingFoundation
import InvestingStorage

protocol PorfolioViewOutput: AnyObject {
    func didRequestRefresh(
        _ option: PorfolioRefreshOptions,
        completion: @escaping () -> Void,
        progress: @escaping (DataBaseManager.UpdatingProgress) -> ()
    )
}

enum PorfolioRefreshOptions: Hashable {
    case all
    case rates
}

class PorfolioViewModel: CancelableObject, ObservableObject {
    @Published var contentState: ContentState = .loading
    @Published var progress: DataBaseManager.UpdatingProgress?
    @Published var totals: [MoneyAmount] = []
    @Published var dataSource: [PorfolioSectionViewModel] = []
    @Published var sortType: SortType = .inProfile
    @Published var isPresentAccounts: Bool = false
    
    lazy var accountsListViewModel = moduleFactory.accountsList(output: self)
    
    private let refreshSubject = CurrentValueSubject<Void, Never>(())

    private weak var output: PorfolioViewOutput?
    private let realmStorage: RealmStoraging
    private let calculatorManager: CalculatorManager

    private let moduleFactory: ModuleFactoring

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
    
    public func instrumentDetailsViewModel(accountId: String, figi: String) -> InstrumentDetailsViewModel {
        moduleFactory.instrumentDetailsView(accountId: accountId, figi: figi)
    }

    public func refresh() async {
        await withCheckedContinuation { configuration in
            refresh(option: .all) {
                configuration.resume()
            }
        }
    }
}

extension PorfolioViewModel: ViewLifeCycleOperator {
    func onAppear() {
        refresh(option: .rates)
        setupUpdateContent()
    }
}

private extension PorfolioViewModel {
    func refresh(option: PorfolioRefreshOptions, completion: @escaping () -> Void = {}) {
        output?.didRequestRefresh(option) {
            DispatchQueue.main.async {
                self.refreshSubject.send()
                self.progress = nil
                completion()
            }
        } progress: { progress in
            DispatchQueue.main.async {
                self.progress = progress
            }
        }
    }
    
    func setupUpdateContent() {
        guard updateViewCancellable == nil else {
            return
        }
        
        contentState = .loading

        updateViewCancellable = Publishers.CombineLatest($sortType, refreshSubject)
            .receive(queue: .global())
            .map { [unowned self] sortType, _ -> [PorfolioSectionViewModel] in
                let accounts = realmStorage.selectedAccounts()

                return accounts.map {
                    map(account: $0, sortType: sortType)
                }
//                .sorted(by: { $0.account.name < $1.account.name })
            }
            .receive(queue: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] dataSource in
                if contentState != .content {
                    contentState = .content
                }
                self.dataSource = dataSource
            })

        $dataSource
            .dropFirst()
            .receive(queue: .global())
            .map { models -> [MoneyAmount] in
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
            .sink(receiveValue: { [unowned self] totals in
                if contentState != .content {
                    contentState = .content
                }

                self.totals = totals
            })
            .store(in: &cancellables)
    }

    func map(account: BrokerAccount, sortType: SortType) -> PorfolioSectionViewModel {
        let uniqueInstrument = Set(account.operations
            .filter { $0.instrumentType != .currency }
            .compactMap { $0.figi })

        var positions = uniqueInstrument.compactMap { figi -> PorfolioPositionViewModel? in
            self.map(account: account, figi: figi)
        }

        soted(positions: &positions, sortType: sortType)

        let uiCurrencies = positions.map { $0.uiCurrency }.unique.sorted()

        let results: [MoneyAmount] = uiCurrencies.map { currency in
            let amount = positions
                .filter { $0.uiCurrency == currency }
                .reduce(0) { $0 + $1.result.value }

            return MoneyAmount(uiCurrency: currency, value: amount)
        }

        return PorfolioSectionViewModel(
            account: account,
            positions: positions,
            results: results
        )
    }

    func map(account: BrokerAccount, figi: String) -> PorfolioPositionViewModel? {
        guard let instrument = realmStorage.share(figi: figi),
              let (result, investResult) = calculatorManager.calculateResult(on: figi, in: account)
        else {
            return nil
        }

        var inPortfolio: PorfolioPositionViewModel.InPortfolio?
        let instrumentInProfile = account.portfolio?.positions.first(where: { $0.figi == figi })

        if let average = investResult,
           let quantity = instrumentInProfile?.quantity,
           let currentCurrencyPrice = instrumentInProfile?.currentCurrencyPrice
        {
            inPortfolio = PorfolioPositionViewModel.InPortfolio(
                quantity: quantity.price,
                price: currentCurrencyPrice,
                average: average
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
            inPortfolio: inPortfolio
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
            let availableCurrency = positions.map { $0.uiCurrency }.unique.sorted(by: >)

            positions = availableCurrency.reduce([]) { result, uiCurrency in
                result + positions
                    .filter { $0.uiCurrency == uiCurrency }
                    .sorted { $0.result.value > $1.result.value }
            }
        }
    }
}

extension PorfolioViewModel: AccountsListOutput {
    func accountsDidSelectAccounts() {
        DispatchQueue.main.async {
            self.isPresentAccounts = false
            self.refreshSubject.send()
        }
    }
}

struct PorfolioSectionViewModel: Hashable, Identifiable {
    var id: Int { hashValue }
    
    let account: BrokerAccount
    let positions: [PorfolioPositionViewModel]
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
