//
//  RealmPosition.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import RealmSwift

public class RealmPosition: EmbeddedObject {
    @Persisted public var averagePositionPrice: RealmPrice?
    @Persisted public var instrumentType: String?
    @Persisted public var quantity: RealmPrice?
    @Persisted public var averagePositionPricePt: RealmPrice?
    @Persisted public var currentNkd: RealmPrice?
    @Persisted public var figi: String?
    @Persisted public var expectedYield: RealmPrice?
}

public extension RealmPosition {
    public static func realmPosition(from position: PortfolioPosition) -> RealmPosition {
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
