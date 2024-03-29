//
//  PortfolioManager.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2022.
//

import Combine
import Foundation
import InvestModels
import InvestingServices
import InvestingStorage

protocol PortfolioManaging {
    func userAccounts() -> AnyPublisher<[BrokerAccount], Error>
    func getPortfolio(for accountId: String) -> AnyPublisher<Portfolio, Never>
    func syncGetFirstSelectedAccount() -> BrokerAccount?
}

class PortfolioManager {
    private let portfolioService: PortfolioServing
    private let realmStorage: RealmStoraging

    init(
        portfolioService: PortfolioServing,
        realmStorage: RealmStoraging
    ) {
        self.portfolioService = portfolioService
        self.realmStorage = realmStorage
    }
}

extension PortfolioManager: PortfolioManaging {
    func userAccounts() -> AnyPublisher<[BrokerAccount], Error> {
        portfolioService.getAccounts()
            .flatMap { [weak self] accounts -> AnyPublisher<[BrokerAccount], Error> in
                self?.realmStorage.saveAccounts(accounts: accounts)

                return Result
                    .Publisher(.success(accounts))
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func getPortfolio(for accountId: String) -> AnyPublisher<Portfolio, Never> {
        portfolioService.getPortfolio(accountId: accountId)
            .flatMap { [weak self] portfolio -> AnyPublisher<Portfolio, Error> in
                self?.realmStorage.save(portfolio: portfolio, for: accountId)

                return Result
                    .Publisher(.success(portfolio))
                    .eraseToAnyPublisher()
            }
            .replaceError(with: .empty)
            .eraseToAnyPublisher()
    }

    func syncGetFirstSelectedAccount() -> BrokerAccount? {
        realmStorage.selectedAccounts().first
    }
}
