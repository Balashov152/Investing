//
//  RealmPortfolio.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import Foundation
import RealmSwift

public class RealmPortfolio: EmbeddedObject {
    @Persisted var totalAmountBonds: RealmPrice?
    @Persisted var totalAmountFutures: RealmPrice?
    @Persisted var totalAmountCurrencies: RealmPrice?
    @Persisted var totalAmountShares: RealmPrice?
    @Persisted var totalAmountEtf: RealmPrice?

    @Persisted var expectedYield: RealmPrice?
    @Persisted var positions = List<RealmPosition>()
}

extension RealmPortfolio {
    static func realmPortfolio(from portfolio: Portfolio) -> RealmPortfolio {
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
