//
//  LogoService.swift
//  Investing
//
//  Created by Sergey Balashov on 15.01.2021.
//

import Foundation
import InvestModels

protocol LogoPosition {
    var instrumentType: InstrumentType { get }
    var ticker: String? { get }
    var isin: String? { get }
    var currency: Currency { get }
}

enum InstrumentLogoService {
    static func logoUrl(for model: LogoPosition) -> URL? {
        switch model.instrumentType {
        case .Stock, .Bond:
            guard let isin = model.isin else {
                return nil
            }

            return LogoService.logoUrl(for: isin)

        case .Currency:
            return LogoService.logoUrl(for: model.currency.rawValue)

        case .Etf:
            guard let ticker = model.ticker else {
                return nil
            }

            return LogoService.logoUrl(for: ticker)
        }
    }
}

enum LogoService {
    static let base = "https://static.tinkoff.ru/brands/traiding/"
    static func logoUrl(for isin: String) -> URL {
        URL(string: base + isin + "x160.png")!
    }
}
