//
//  Portfolio.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import Foundation

struct Portfolio: Codable, Equatable {
    let totalAmountBonds: Price?
    let totalAmountFutures: Price?
    let totalAmountCurrencies: Price?
    let expectedYield: Price?
    let positions: [PortfolioPosition]
    let totalAmountShares: Price?
    let totalAmountEtf: Price?
}

extension Portfolio {
    init(portfolio: RealmPortfolio) {
        totalAmountBonds = portfolio.totalAmountBonds.map(Price.init)
        totalAmountFutures = portfolio.totalAmountFutures.map(Price.init)
        totalAmountCurrencies = portfolio.totalAmountCurrencies.map(Price.init)
        totalAmountShares = portfolio.totalAmountShares.map(Price.init)
        totalAmountEtf = portfolio.totalAmountEtf.map(Price.init)
        expectedYield = portfolio.expectedYield.map(Price.init)
        positions = portfolio.positions.map(PortfolioPosition.init)
    }
}
