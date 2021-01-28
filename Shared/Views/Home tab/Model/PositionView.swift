//
//  PositionView.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Foundation
import InvestModels
import SwiftUI

extension PositionView: LogoPosition {}

struct PositionView: Hashable, Identifiable {
    init(position: Position) {
        self.init(position: position,
                  expectedYield: position.expectedYield,
                  averagePositionPrice: position.averagePositionPrice)
    }
    
    init(currency: CurrencyPosition) {
        self.name = currency.currency.rawValue
        self.ticker = currency.currency.rawValue
        self.instrumentType = .Currency
        self.blocked = currency.blocked
        self.lots = 0 // currency.balance
        self.isin = currency.currency.rawValue
        self.expectedYield = MoneyAmount(currency: currency.currency, value: currency.balance)
        self.averagePositionPrice = MoneyAmount(currency: currency.currency, value: currency.balance)
    }

    init(position: Position, expectedYield: MoneyAmount, averagePositionPrice: MoneyAmount) {
        name = position.name
        ticker = position.ticker
        instrumentType = position.instrumentType
        blocked = position.blocked
        lots = position.lots
        isin = position.isin
        self.expectedYield = expectedYield
        self.averagePositionPrice = averagePositionPrice
    }

    public let name: String?
    public let ticker: String?

    public let isin: String?
    public let instrumentType: InstrumentType?

    public let blocked: Double?
    public let lots: Int

    public let expectedYield: MoneyAmount
    public let averagePositionPrice: MoneyAmount
}

extension PositionView {
    var currency: Currency {
        averagePositionPrice.currency
    }

    var totalBuyPayment: MoneyAmount {
        MoneyAmount(currency: currency,
                    value: averagePositionPrice.value * Double(lots))
    }

    var totalInProfile: MoneyAmount {
        MoneyAmount(currency: currency,
                    value: totalBuyPayment.value + expectedYield.value)
    }

    var deltaAveragePositionPrice: MoneyAmount {
        MoneyAmount(currency: expectedYield.currency,
                    value: expectedYield.value / Double(lots))
    }

    var averagePositionPriceNow: MoneyAmount {
        MoneyAmount(currency: currency,
                    value: totalInProfile.value / Double(lots))
    }

    var expectedPercent: Double {
        (expectedYield.value / totalBuyPayment.value) * 100
    }
}
