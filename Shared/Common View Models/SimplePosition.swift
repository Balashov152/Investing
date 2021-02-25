//
//  SimplePosition.swift
//  Investing
//
//  Created by Sergey Balashov on 25.02.2021.
//

import Foundation
import InvestModels

struct SimplePosition: Hashable, Identifiable, LogoPosition {
    internal init(position: Position) {
        name = position.name ?? position.ticker
        instrumentType = position.instrumentType
        ticker = position.ticker
        isin = position.isin
        currency = position.currency
    }

    internal init(position: CurrencyPosition) {
        name = position.currency.rawValue
        instrumentType = .Currency
        ticker = position.currency.rawValue
        isin = nil
        currency = position.currency
    }

    let name: String
    var instrumentType: InstrumentType
    var ticker: String
    var isin: String?
    var currency: Currency
}
