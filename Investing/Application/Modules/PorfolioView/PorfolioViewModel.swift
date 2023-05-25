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
        completion: ((Subscribers.Completion<Error>) -> Void)?,
        progress: @escaping (DataBaseManager.UpdatingProgress) -> ()
    )
}

enum PorfolioRefreshOptions: Hashable {
    case all
    case rates
}

extension PorfolioViewModel {
    enum HeaderView: Hashable, Identifiable {
        var id: Int { hashValue }
        
        case progress(String)
        case error(String)
        case total(MoneyAmount)
    }
}

class PorfolioViewModel: CancelableObject, ObservableObject {
    
    // MARK: - ViewState
    
    var headerViews: [HeaderView] {
        var headerViews: [HeaderView] = []
        
        if let error {
            headerViews.append(.error(error))
        }
        
        if let progress {
            headerViews.append(.progress(progress.title))
        }
        
        totals.forEach { headerViews.append(.total($0)) }
        
        return headerViews
    }

    @Published var dataSource: [PorfolioSectionViewModel] = []
    @Published var sortType: SortType = .inProfile
    @Published var instrumentDetailsViewModel: InstrumentDetailsViewModel?
    @Published var accountsListViewModel: AccountsListViewModel?
    
    @Published private var error: String?
    @Published private var progress: DataBaseManager.UpdatingProgress?
    @Published private var totals: [MoneyAmount] = []
    
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
    
    public func refresh() async {
        await withCheckedContinuation { configuration in
            refresh(option: .all) {
                configuration.resume()
            }
        }
    }
    
    public func refreshRates() {
        refresh(option: .rates)
    }
    
    public func openAccounts() {
        accountsListViewModel = moduleFactory.accountsList(output: self)
    }
    
    public func openDetails(accountId: String, figi: String) {
        instrumentDetailsViewModel = moduleFactory.instrumentDetailsView(accountId: accountId, figi: figi)
    }
}

extension PorfolioViewModel: ViewLifeCycleOperator {
    func onAppear() {
        setupUpdateContent()
    }
}

private extension PorfolioViewModel {
    func refresh(option: PorfolioRefreshOptions, completion: @escaping () -> Void = {}) {
        DispatchQueue.main.async {
            self.error = nil
        }

        output?.didRequestRefresh(option) { result in
            switch result {
            case .finished:
                break
            case .failure(let error):
                self.error = error.localizedDescription
            }
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
        
        updateViewCancellable = Publishers.CombineLatest($sortType, refreshSubject)
            .receive(queue: .global())
            .map { [unowned self] sortType, _ -> [PorfolioSectionViewModel] in
                let accounts = realmStorage.selectedAccounts()

                return accounts.map {
                    map(account: $0, sortType: sortType)
                }
            }
            .receive(queue: .main)
            .sink(receiveValue: { [unowned self] dataSource in
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
            .receive(queue: .main)
            .sink(receiveValue: { [unowned self] totals in
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
            self.accountsListViewModel = nil
            self.refreshSubject.send()
        }
    }
}

struct PorfolioSectionViewModel: Identifiable {
    var id: String { account.id }
    
    let account: BrokerAccount
    let positions: [PorfolioPositionViewModel]
    let results: [MoneyAmount]
}

extension PorfolioViewModel {
    enum SortType: Int, CaseIterable {
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
