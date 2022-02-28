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

    private let realmStorage: RealmStoraging
    let moduleFactory: ModuleFactoring

    init(
        realmStorage: RealmStoraging,
        moduleFactory: ModuleFactoring
    ) {
        self.realmStorage = realmStorage
        self.moduleFactory = moduleFactory
    }
}

extension PorfolioViewModel: ViewLifeCycleOperator {
    func onAppear() {
        $sortType
            .receive(on: DispatchQueue.global())
            .map { [unowned self] sortType -> [PorfolioSectionViewModel] in
                realmStorage.selectedAccounts().map {
                    map(account: $0, sortType: sortType)
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.dataSource, on: self)
            .store(in: &cancellables)
    }
}

extension PorfolioViewModel {
    func map(account: BrokerAccount, sortType: SortType) -> PorfolioSectionViewModel {
        let uniqueInstrument = Set(account.operations.compactMap { $0.figi })

        var operationsVM = uniqueInstrument.compactMap { figi -> PorfolioPositionViewModel? in
            self.map(account: account, figi: figi)
        }

        switch sortType {
        case .name:
            operationsVM = operationsVM.sorted { $0.name < $1.name }
        case .inProfile:

            let inPortfolio = operationsVM
                .filter { $0.inPortfolio != nil }
                .sorted { $0.name < $1.name }

            let notPortfolio = operationsVM
                .filter { $0.inPortfolio == nil }
                .sorted { $0.name < $1.name }

            operationsVM = inPortfolio + notPortfolio

        case .profit:
            let availableCurrency = Set(operationsVM.map { $0.uiCurrency })

            operationsVM = availableCurrency.sorted().reduce([]) { result, uiCurrency in
                result + operationsVM
                    .filter { $0.uiCurrency == uiCurrency }
                    .sorted { $0.result.value > $1.result.value }
            }
        }

        return PorfolioSectionViewModel(accountName: account.name,
                                        operations: operationsVM)
    }

    func map(account: BrokerAccount, figi: String) -> PorfolioPositionViewModel? {
        guard let instrument = realmStorage.share(figi: figi) else {
            return nil
        }

        let instrumentInProfile = account.portfolio?.positions.first(where: { $0.figi == figi })
        let allOperations = account.operations.filter { $0.figi == figi }

        var resultAmount: Double = allOperations.reduce(0) { result, operation in
            if instrument.ticker == "MAC" {
                print(operation.payment?.price ?? 0)
            }
            return result + (operation.payment?.price ?? 0)
        }

        var average: MoneyAmount?
        var inPortfolio: PorfolioPositionViewModel.InPortfolio?

        if let quantity = instrumentInProfile?.quantity,
           let positionPrice = instrumentInProfile?.inPortfolioPrice
        {
            resultAmount += positionPrice.value
            let averageAmount = (abs(resultAmount) + positionPrice.value) / quantity.price

            average = MoneyAmount(currency: instrument.currency, value: averageAmount)

            inPortfolio = PorfolioPositionViewModel.InPortfolio(
                quantity: quantity.price,
                price: average!
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
}

extension PorfolioViewModel: AccountsListOutput {
    func accountsDidSelectAccounts() {
        isPresentAccounts = false
    }
}

struct PorfolioSectionViewModel: Identifiable {
    var id: String { accountName }

    let accountName: String
    let operations: [PorfolioPositionViewModel]
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
