//
//  DataBaseManager.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import Combine

protocol DataBaseManaging {
    func updateDataBase() -> AnyPublisher<Void, Error>
}

extension DataBaseManager {
    enum DataBaseError: Error {
        case selectedAccountsNotFound
    }
}

struct DataBaseManager {
    private let realmStorage: RealmStoraging
    private let operationsManager: OperationsManaging
    private let instrumentsManager: InstrumentsManaging
    private let portfolioManager: PortfolioManaging

    init(
        operationsManager: OperationsManaging,
        instrumentsManager: InstrumentsManaging,
        portfolioManager: PortfolioManaging,
        realmStorage: RealmStoraging
    ) {
        self.operationsManager = operationsManager
        self.instrumentsManager = instrumentsManager
        self.portfolioManager = portfolioManager
        self.realmStorage = realmStorage
    }
}

extension DataBaseManager: DataBaseManaging {
    func updateDataBase() -> AnyPublisher<Void, Error> {
        instrumentsManager.updateInstruments()
            .tryMap { _ -> AnyPublisher<Void, Error> in
                operationsManager.updateOperations()
            }
            .switchToLatest()
            .tryMap { _ -> AnyPublisher<Void, Error> in
                // Load portfolios for every account
                realmStorage
                    .selectedAccounts()
                    .map { account in
                        self.portfolioManager
                            .getPortfolio(for: account.id)
                            .eraseToAnyPublisher()
                            .mapToVoid()
                    }
                    .combineLatest
                    .eraseToAnyPublisher()
                    .mapToVoid()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
