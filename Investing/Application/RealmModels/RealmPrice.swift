//
//  RealmPrice.swift
//  Investing
//
//  Created by Sergey Balashov on 27.01.2022.
//

import Foundation
import RealmSwift

public class RealmPrice: EmbeddedObject {
    @Persisted var nano: Int = 0
    @Persisted var currency: String = ""
    @Persisted var units: String = ""
}

extension RealmPrice {
    static func realmPrice(from price: Price) -> RealmPrice {
        let realmPrice = RealmPrice()
        realmPrice.currency = price.currency.rawValue
        realmPrice.units = price.units
        realmPrice.nano = price.nano

        return realmPrice
    }
}
