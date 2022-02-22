//
//  RealmCandle.swift
//  Investing
//
//  Created by Sergey Balashov on 01.02.2022.
//

import Foundation
import RealmSwift

public class RealmCandle: Object {
    @Persisted(primaryKey: true) var figi: String?
    @Persisted var volume: String?
    @Persisted var isComplete: Bool = false
    @Persisted var time: Date?

    @Persisted var high: RealmPrice?
    @Persisted var low: RealmPrice?
    @Persisted var close: RealmPrice?
    @Persisted var open: RealmPrice?
}

public extension RealmCandle {
    static func realmCandle(from candle: CandleV2) -> RealmCandle {
        let realmCandle = RealmCandle()
        realmCandle.volume = candle.volume
        realmCandle.isComplete = candle.isComplete
        realmCandle.time = candle.time

        realmCandle.high = candle.high.map(RealmPrice.realmPrice(from:))
        realmCandle.low = candle.low.map(RealmPrice.realmPrice(from:))
        realmCandle.close = candle.close.map(RealmPrice.realmPrice(from:))
        realmCandle.open = candle.open.map(RealmPrice.realmPrice(from:))

        return realmCandle
    }
}
