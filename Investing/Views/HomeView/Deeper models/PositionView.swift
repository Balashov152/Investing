//
//  PositionView.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Foundation
import InvestModels
import SwiftUI

struct PositionView: Hashable, Identifiable, LogoPosition {
    init(position: Position, percentInProfile: Double, blocked: MoneyAmount?) {
        self.init(position: position,
                  percentInProfile: percentInProfile,
                  blocked: blocked,
                  expectedYield: position.expectedYield,
                  averagePositionPrice: position.averagePositionPrice,
                  averagePositionPriceNow: position.averagePositionPriceNow)
    }

    init(currency: CurrencyPosition, percentInProfile: Double) {
        name = currency.currency.rawValue
        ticker = currency.currency.rawValue
        instrumentType = .Currency
        blocked = currency.blocked.addCurrency(currency.currency)
        lots = 1 // currency.balance
        isin = currency.currency.rawValue
        self.percentInProfile = percentInProfile
        expectedYield = MoneyAmount(currency: currency.currency, value: 0)
        averagePositionPrice = MoneyAmount(currency: currency.currency, value: currency.balance)
        averagePositionPriceNow = MoneyAmount(currency: currency.currency, value: currency.balance)
    }

    init(position: Position, percentInProfile: Double, blocked: MoneyAmount?,
         expectedYield: MoneyAmount,
         averagePositionPrice: MoneyAmount, averagePositionPriceNow: MoneyAmount)
    {
        name = position.name
        ticker = position.ticker
        instrumentType = position.instrumentType
        isin = position.isin
        lots = Double(position.lots)

        self.percentInProfile = percentInProfile
        self.blocked = blocked

        self.expectedYield = expectedYield
        self.averagePositionPrice = averagePositionPrice
        self.averagePositionPriceNow = averagePositionPriceNow
    }

    public let name: String?
    public let ticker: String

    public let isin: String?
    public let instrumentType: InstrumentType

    public let blocked: MoneyAmount?

    public let lots: Double

    public let percentInProfile: Double
    public let expectedYield: MoneyAmount
    public let averagePositionPrice: MoneyAmount
    public let averagePositionPriceNow: MoneyAmount
}

extension PositionView {
    var currency: Currency {
        averagePositionPrice.currency
    }

    var totalBuyPayment: MoneyAmount {
        MoneyAmount(currency: currency,
                    value: averagePositionPrice.value * lots)
    }

    var totalInProfile: MoneyAmount {
        MoneyAmount(currency: currency,
                    value: totalBuyPayment.value + expectedYield.value)
    }

    var deltaAveragePositionPrice: MoneyAmount {
        MoneyAmount(currency: currency,
                    value: expectedYield.value / lots)
    }

    var expectedPercent: Double {
        (expectedYield.value / totalBuyPayment.value) * 100
    }
}
