//
//  Portfolio.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import Foundation

public struct Portfolio: Codable, Equatable {
    public let totalAmountBonds: Price?
    public let totalAmountFutures: Price?
    public let totalAmountCurrencies: Price?
    public let expectedYield: Price?
    public let positions: [PortfolioPosition]
    public let totalAmountShares: Price?
    public let totalAmountEtf: Price?
}
 
public extension Portfolio {
    static let empty: Portfolio = Portfolio(
        totalAmountBonds: nil,
        totalAmountFutures: nil,
        totalAmountCurrencies: nil,
        expectedYield: nil,
        positions: [],
        totalAmountShares: nil,
        totalAmountEtf: nil
    )
}

public extension Portfolio {
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
