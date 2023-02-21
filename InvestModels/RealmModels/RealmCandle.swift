//
//  RealmCandle.swift
//  Investing
//
//  Created by Sergey Balashov on 01.02.2022.
//

import Foundation
import RealmSwift

public class RealmCandle: Object {
    @Persisted(primaryKey: true) var id: String?

    @Persisted public var figi: String?
    @Persisted public var volume: String?
    @Persisted public var isComplete: Bool = false
    @Persisted public var time: Date?

    @Persisted public var high: RealmPrice?
    @Persisted public var low: RealmPrice?
    @Persisted public var close: RealmPrice?
    @Persisted public var open: RealmPrice?
}

public extension RealmCandle {
    static func realmCandle(from candle: CandleV2) -> RealmCandle {
        let realmCandle = RealmCandle()
        realmCandle.id = (candle.figi ?? "") + "_" + DateFormatter.iso8601.string(from: candle.time)

        realmCandle.figi = candle.figi
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
