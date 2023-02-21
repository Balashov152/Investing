//
//  DependencyFactory.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2022.
//

import Foundation
import InvestingServices
import InvestingStorage

struct DependencyFactory {
    private let services: InvestingServicesFactory
    
    init(services: InvestingServicesFactory) {
        self.services = services
    }
    
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
        services.portfolioService
    }

    var operationsService: OperationsServing {
        services.operationsService
    }

    var shareService: ShareServing {
        services.shareService
    }

    // MARK: - Storages

    var realmStorage: RealmStoraging {
        RealmStorage()
    }
}
