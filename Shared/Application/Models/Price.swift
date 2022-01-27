//
//  Price.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2022.
//

import Foundation

struct Price: Codable {
    let nano: Int?
    let currency: Currency?
    let units: String?
}

extension Price {
    enum Currency: String, Codable {
        case usd, rub, eur, cad, ils, chf, gbp
    }
}

extension Price {
    init(price: RealmPrice) {
        currency = Currency(rawValue: price.currency ?? "")
        units = price.units
        nano = price.nano
    }
}
