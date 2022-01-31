//
//  PorfolioPosition.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import Foundation

struct PortfolioPosition: Codable, Equatable {
    let averagePositionPrice: Price?
    let instrumentType: InstrumentTypeV2?
    let quantity: Double?
    let averagePositionPricePt: Price?
    let currentNkd: Price?
    let figi: String?
    let expectedYield: Double?
}

extension PortfolioPosition {
    init(position: RealmPosition) {
        averagePositionPrice = position.averagePositionPrice.map(Price.init)
        averagePositionPricePt = position.averagePositionPricePt.map(Price.init)
        currentNkd = position.currentNkd.map(Price.init)
        figi = position.figi
        expectedYield = position.expectedYield
        instrumentType = InstrumentTypeV2(rawValue: position.instrumentType ?? "")
        quantity = position.quantity
    }
}

extension PortfolioPosition {
    var fullSpend: Double {
        (quantity ?? 0) * (averagePositionPrice?.price ?? 0)
    }
}
