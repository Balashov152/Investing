//
//  LogoService.swift
//  Investing
//
//  Created by Sergey Balashov on 15.01.2021.
//

import Foundation
import InvestModels

struct LogoService {
    static let base = "http://static.tinkoff.ru/brands/traiding/"
    static func logoUrl(for isin: String) -> URL {
        URL(string: base + isin + "x160.png")!
    }
}
