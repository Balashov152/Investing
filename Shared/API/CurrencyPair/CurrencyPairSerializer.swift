//
//  CurrencyPairSerializer.swift
//  Investing
//
//  Created by Sergey Balashov on 23.12.2020.
//

import Foundation
import InvestModels

struct CurrencyPairSerializer {
    static func serialize(json: [String: Any]) -> [CurrencyPair] {
        guard let rates = json["rates"] as? [String: [String: Any]] else {
            return []
        }

        let pairs = rates.compactMap { key, value -> CurrencyPair? in
            if let date = DateFormatter.format("yyyy-MM-dd").date(from: key),
               let usd = value["USD"] as? Double, let eur = value["EUR"] as? Double
            {
                return CurrencyPair(date: date, USD: usd, EUR: eur)
            }
            return nil
        }

        return pairs
    }
}
