//
//  LogoService.swift
//  Investing
//
//  Created by Sergey Balashov on 15.01.2021.
//

import Foundation
import InvestModels

struct InstrumentLogoService {
    static func logoUrl(for type: InstrumentType?, isin: String?) -> URL? {
        guard type == .Stock, let isin = isin else {
            return nil
        }

        return LogoService.logoUrl(for: isin)
    }
}

enum LogoService {
    static let base = "https://static.tinkoff.ru/brands/traiding/"
    static func logoUrl(for isin: String) -> URL {
        URL(string: base + isin + "x160.png")!
    }
}
