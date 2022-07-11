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
        let unit = Double(units) ?? 0
        var nanoInt = Int(nano)

        if nanoInt == 0 {
            return unit
        }

        assert(nanoInt < 0 && unit <= 0 || nanoInt > 0 && unit >= 0)

        while nanoInt.string.last == "0" {
            nanoInt /= 10
        }

        var nanoWithUnit = Double(nanoInt)

        (0 ..< abs(nanoInt).string.count).forEach { _ in
            nanoWithUnit /= 10
        }

        return unit + nanoWithUnit
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
    enum Currency: String, Codable, Equatable, CaseIterable {
        case usd, rub, eur, cad, ils, chf, gbp, hkd

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            
            if Currency.allCases.map({ $0.rawValue }).contains(rawValue) {
                self.init(rawValue: rawValue)!
            } else {
                self = .usd
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
