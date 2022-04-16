//
//  DependencyFactory.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2022.
//

import Foundation

struct DependencyFactory {
    // MARK: - Managers

    var calculatorManager: CalculatorManager {
        CalculatorManager(
            realmStorage: realmStorage
        )
    }

    var portfolioManager: PortfolioManaging {
        PortfolioManager(
            portfolioService: portfolioService,
            realmStorage: realmStorage
        )
    }

    var operationsManager: OperationsManaging {
        OperationsManager(
            operationsService: operationsService,
            realmStorage: realmStorage
        )
    }

    var instrumentsManager: InstrumentsManaging {
        InstrumentsManager(
            shareService: shareService,
            realmStorage: realmStorage
        )
    }

    var dataBaseManager: DataBaseManaging {
        DataBaseManager(
            operationsManager: operationsManager,
            instrumentsManager: instrumentsManager,
            portfolioManager: portfolioManager,
            realmStorage: realmStorage
        )
    }

    // MARK: - Services

    var portfolioService: PortfolioServing {
        PortfolioService()
    }

    var operationsService: OperationsServing {
        OperationsServiceV2()
    }

    var shareService: ShareServing {
        ShareService()
    }

    // MARK: - Storages

    var realmStorage: RealmStoraging {
        RealmStorage()
    }
}
