//
//  RealmPosition.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import RealmSwift

public class RealmPosition: EmbeddedObject {
    @Persisted var averagePositionPrice: RealmPrice?
    @Persisted var instrumentType: String?
    @Persisted var quantity: RealmPrice?
    @Persisted var averagePositionPricePt: RealmPrice?
    @Persisted var currentNkd: RealmPrice?
    @Persisted var figi: String?
    @Persisted var expectedYield: RealmPrice?
}

extension RealmPosition {
    static func realmPosition(from position: PortfolioPosition) -> RealmPosition {
        let realmPosition = RealmPosition()

        realmPosition.averagePositionPrice = position.averagePositionPrice.map(RealmPrice.realmPrice(from:))
        realmPosition.averagePositionPricePt = position.averagePositionPricePt.map(RealmPrice.realmPrice(from:))
        realmPosition.currentNkd = position.currentNkd.map(RealmPrice.realmPrice(from:))
        realmPosition.expectedYield = position.expectedYield.map(RealmPrice.realmPrice(from:))

        realmPosition.figi = position.figi
        realmPosition.instrumentType = position.instrumentType?.rawValue
        realmPosition.quantity = position.quantity.map(RealmPrice.realmPrice(from:))

        return realmPosition
    }
}
