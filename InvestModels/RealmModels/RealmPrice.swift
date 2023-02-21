//
//  RealmPrice.swift
//  Investing
//
//  Created by Sergey Balashov on 27.01.2022.
//

import Foundation
import RealmSwift

public class RealmPrice: EmbeddedObject {
    @Persisted public var nano: Int = 0
    @Persisted public var currency: String = ""
    @Persisted public var units: String = ""
}

public extension RealmPrice {
    static func realmPrice(from price: Price) -> RealmPrice {
        let realmPrice = RealmPrice()
        realmPrice.currency = price.currency.rawValue
        realmPrice.units = price.units
        realmPrice.nano = price.nano

        return realmPrice
    }
}
