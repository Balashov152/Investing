//
//  PortfolioManager.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2022.
//

import Combine
import Foundation

protocol PortfolioManaging {
    func userAccounts() -> AnyPublisher<[BrokerAccount], Error>
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
}
