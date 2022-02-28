//
//  Price.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2022.
//

import Foundation

public struct Price: Codable, Equatable {
    let nano: Int
    let currency: Currency
    let units: String

    var price: Double {
        let unit = Int(units) ?? 0
        var nanoWithUnit = Double(nano)

        if unit > 0 {
            (0 ..< nano.string.count).forEach { _ in
                nanoWithUnit /= 10
            }
        } else {
            (0 ... nano.string.count).forEach { _ in
                nanoWithUnit /= 10
            }
        }

        return Double(unit) + nanoWithUnit
    }

    enum CodingKeys: String, CodingKey {
        case nano
        case currency
        case units
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        nano = try values.decodeIfPresent(forKey: .nano, default: 0)
        currency = try values.decodeIfPresent(forKey: .currency, default: .usd)
        units = try values.decodeIfPresent(forKey: .units, default: "0")
    }
}

public extension Price {
    enum Currency: String, Codable, Equatable {
        case usd, rub, eur, cad, ils, chf, gbp

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)

            if rawValue.isEmpty {
                self = .usd
            } else {
                self.init(rawValue: rawValue)!
            }
        }
    }
}

public extension Price {
    init(price: RealmPrice) {
        currency = Currency(rawValue: price.currency) ?? .usd
        units = price.units
        nano = price.nano
    }
}
