//
//  RealmPortfolio.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import Foundation
import RealmSwift

public class RealmPortfolio: EmbeddedObject {
    @Persisted public var totalAmountBonds: RealmPrice?
    @Persisted public var totalAmountFutures: RealmPrice?
    @Persisted public var totalAmountCurrencies: RealmPrice?
    @Persisted public var totalAmountShares: RealmPrice?
    @Persisted public var totalAmountEtf: RealmPrice?

    @Persisted public var expectedYield: RealmPrice?
    @Persisted public var positions = List<RealmPosition>()
}

public extension RealmPortfolio {
    public static func realmPortfolio(from portfolio: Portfolio) -> RealmPortfolio {
        let realmPortfolio = RealmPortfolio()
        realmPortfolio.totalAmountBonds = portfolio.totalAmountBonds.map(RealmPrice.realmPrice(from:))
        realmPortfolio.totalAmountFutures = portfolio.totalAmountFutures.map(RealmPrice.realmPrice(from:))
        realmPortfolio.totalAmountCurrencies = portfolio.totalAmountCurrencies.map(RealmPrice.realmPrice(from:))
        realmPortfolio.totalAmountShares = portfolio.totalAmountShares.map(RealmPrice.realmPrice(from:))
        realmPortfolio.totalAmountEtf = portfolio.totalAmountEtf.map(RealmPrice.realmPrice(from:))
        realmPortfolio.expectedYield = portfolio.expectedYield.map(RealmPrice.realmPrice(from:))
        realmPortfolio.positions.append(objectsIn: portfolio.positions.map(RealmPosition.realmPosition(from:)))

        return realmPortfolio
    }
}
