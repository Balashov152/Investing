//
//  PositionViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 01.06.2023.
//

import Foundation
import InvestModels

struct PositionViewModel: Hashable, Identifiable, LogoPosition {
    var id: String { figi }
    var deeplinkURL: URL { URL(string: "https://www.tinkoff.ru/invest/stocks/\(ticker)")! }

    var average: MoneyAmount? {
        guard let average = inPortfolio?.average, average.value > 0 else {
            return nil
        }

        return average
    }

    var quantity: Double? { inPortfolio?.quantity }
    
    var currentPrice: MoneyAmount? {
        inPortfolio.map {
            print("currentPrice \($0)")
            
            return MoneyAmount(
                currency: $0.price.currency,
                value: $0.price.value
            )
        }
    }

    var deltaPercent: Double? {
        guard let inPortfolio else { return nil }
        let current = inPortfolio.price.value
        let average = inPortfolio.average.value

        if current < average { // I'm in minus
            let percent = current / average
            return (percent - 1) * 100
        }
        
        let percent = abs(average) / current
        return abs(percent - 1) * 100
    }
    
    let figi: String
    let name: String
    let ticker: String
    let isin: String?

    let uiCurrency: UICurrency
    let instrumentType: InstrumentType

    let result: MoneyAmount
    let inPortfolio: InPortfolio?

    init(
        figi: String,
        name: String,
        ticker: String,
        isin: String? = nil,
        uiCurrency: UICurrency,
        instrumentType: InstrumentType,
        result: MoneyAmount,
        inPortfolio: PositionViewModel.InPortfolio?
    ) {
        self.figi = figi
        self.name = name
        self.ticker = ticker
        self.isin = isin
        self.uiCurrency = uiCurrency
        self.instrumentType = instrumentType
        self.result = result
        self.inPortfolio = inPortfolio
    }
}

extension PositionViewModel {
    struct InPortfolio: Hashable {
        let quantity: Double
        let price: MoneyAmount
        let average: MoneyAmount
    }
}

