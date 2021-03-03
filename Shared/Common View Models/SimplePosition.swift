//
//  SimplePosition.swift
//  Investing
//
//  Created by Sergey Balashov on 25.02.2021.
//

import Foundation
import InvestModels

struct SimplePosition: Hashable, Identifiable, LogoPosition {
    internal init(position: Position, averageNow: MoneyAmount) {
        name = position.name ?? position.ticker
        instrumentType = position.instrumentType
        ticker = position.ticker
        isin = position.isin
        currency = position.currency
        self.averageNow = averageNow
    }

    let name: String
    let instrumentType: InstrumentType
    let ticker: String
    let isin: String?
    let currency: Currency
    let averageNow: MoneyAmount
}
