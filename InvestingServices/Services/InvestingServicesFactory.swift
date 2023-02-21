//
//  InvestingServicesFactory.swift
//  InvestingServices
//
//  Created by Sergey Balashov on 21.02.2023.
//

import Foundation

public struct InvestingServicesFactory {
    public init() {}
    
    public var portfolioService: PortfolioServing {
        PortfolioService()
    }

    public var operationsService: OperationsServing {
        OperationsServiceV2()
    }

    public var shareService: ShareServing {
        ShareService()
    }
}
