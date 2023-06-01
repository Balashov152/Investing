//
//  PorfolioPosition.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import Foundation

public struct PortfolioPosition: Codable, Equatable {
    public let averagePositionPrice: Price?
    public let instrumentType: InstrumentTypeV2?
    public let quantity: Price?
    public let averagePositionPricePt: Price?
    public let currentNkd: Price?
    public let figi: String?
    public let expectedYield: Price?
    
    public var currentCurrencyPrice: MoneyAmount? {
        guard let quantity = quantity,
              let averagePositionPrice = averagePositionPrice,
              let expectedYield = expectedYield else {
            return nil
        }

        return MoneyAmount(
            currency: quantity.currency,
            value: averagePositionPrice.price + expectedYield.price / quantity.price
        )
    }

    public var inPortfolioPrice: MoneyAmount? {
        guard let quantity = quantity,
              let averagePositionPrice = averagePositionPrice,
              let expectedYield = expectedYield else {
            return nil
        }
        
        var value: Double = quantity.price * averagePositionPrice.price + expectedYield.price
        
        if let currentNkd {
            print("currentNkd", currentNkd)
            value += currentNkd.price
        }

        return MoneyAmount(currency: quantity.currency, value: value)
    }
}

public extension PortfolioPosition {
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
    public var fullSpend: Double {
        (quantity?.price ?? 0) * (averagePositionPrice?.price ?? 0)
    }
}
