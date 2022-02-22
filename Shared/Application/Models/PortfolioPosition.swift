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
    let quantity: Price?
    let averagePositionPricePt: Price?
    let currentNkd: Price?
    let figi: String?
    let expectedYield: Price?
}

extension PortfolioPosition {
    init(position: RealmPosition) {
        figi = position.figi

        averagePositionPrice = position.averagePositionPrice.map(Price.init)
        averagePositionPricePt = position.averagePositionPricePt.map(Price.init)
        currentNkd = position.currentNkd.map(Price.init)
        expectedYield = position.expectedYield.map(Price.init)
        instrumentType = InstrumentTypeV2(rawValue: position.instrumentType ?? "")
        quantity = position.quantity.map(Price.init)
    }
}

extension PortfolioPosition {
    var fullSpend: Double {
        (quantity?.price ?? 0) * (averagePositionPrice?.price ?? 0)
    }
}
