//
//  DataBaseManager.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import Combine
import Foundation

protocol DataBaseManaging {
    func updateDataBase(progress: @escaping (DataBaseManager.UpdatingProgress) -> ()) -> AnyPublisher<Void, Error>
    func updatePortfolio(progress: @escaping (DataBaseManager.UpdatingProgress) -> ()) -> AnyPublisher<Void, Error>
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
    func updateDataBase(progress: @escaping (UpdatingProgress) -> ()) -> AnyPublisher<Void, Error> {
        instrumentsManager.updateInstruments { progress(.instruments(progress: $0)) }
            .flatMap { _ -> AnyPublisher<Void, Error> in
                operationsManager.updateOperations { progress(.operations(progress: $0)) }
            }
            .flatMap { _ -> AnyPublisher<Void, Error> in
                // Load portfolios for every account
                updatePortfolio(progress: progress)
            }
            .eraseToAnyPublisher()
    }
    
    func updatePortfolio(progress: @escaping (UpdatingProgress) -> ()) -> AnyPublisher<Void, Error> {
        let publishers = realmStorage.selectedAccounts()
            .map { account in
                self.portfolioManager.getPortfolio(for: account.id)
                    .handleEvents(receiveSubscription: { _ in progress(.portfolio(account: account)) })
            }
        
        return Publishers.Sequence(sequence: publishers)
            .flatMap(maxPublishers: .max(1), { $0.delay(for: Constants.requestDelay, scheduler: DispatchQueue.global()) })
            .collect(publishers.count)
            .mapVoid()
            .eraseToAnyPublisher()
    }
}

extension DataBaseManager {
    enum UpdatingProgress {
        case instruments(progress: InstrumentsManager.UpdatingProgress)
        case operations(progress: OperationsManager.UpdatingProgress)
        case portfolio(account: BrokerAccount)
        
        var title: String {
            switch self {
            case let .instruments(progress):
                return "Instrument: \(progress.rawValue.capitalized)"
            case let .operations(progress):
                return "Operations for: \(progress.account.name) (\(progress.progress.current)/\(progress.progress.all))"
            case let .portfolio(account):
                return "Portfolio for: \(account.name)"
            }
        }
    }
}
