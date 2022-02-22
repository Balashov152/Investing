//
//  CandleV2.swift
//  Investing
//
//  Created by Sergey Balashov on 01.02.2022.
//

import Foundation

public class CandleV2: Codable {
    var figi: String?
    let volume: String?
    let time: Date?
    let isComplete: Bool

    let high: Price?
    let low: Price?
    let close: Price?
    let open: Price?

    enum CodingKeys: String, CodingKey {
        case volume
        case high
        case low
        case time
        case close
        case open
        case isComplete
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        figi = nil
        volume = try values.decodeIfPresent(forKey: .volume)
        high = try values.decodeIfPresent(forKey: .high)
        low = try values.decodeIfPresent(forKey: .low)
        time = try values.decodeIfPresent(forKey: .time)
        close = try values.decodeIfPresent(forKey: .close)
        open = try values.decodeIfPresent(forKey: .open)
        isComplete = try values.decodeIfPresent(forKey: .isComplete, default: true)
    }

    public init(candle: RealmCandle) {
        figi = candle.figi
        volume = candle.volume
        isComplete = candle.isComplete
        time = candle.time

        high = candle.high.map(Price.init)
        low = candle.low.map(Price.init)
        close = candle.close.map(Price.init)
        open = candle.open.map(Price.init)
    }

    public init(volume: String?, time: Date?, isComplete: Bool, high: Price?, low: Price?, close: Price?, open: Price?) {
        figi = nil
        self.volume = volume
        self.time = time
        self.isComplete = isComplete
        self.high = high
        self.low = low
        self.close = close
        self.open = open
    }
}

public extension CandleV2 {
    enum Interval: String, Codable {
        case CANDLE_INTERVAL_UNSPECIFIED
        case CANDLE_INTERVAL_1_MIN
        case CANDLE_INTERVAL_5_MIN
        case CANDLE_INTERVAL_15_MIN
        case CANDLE_INTERVAL_HOUR
        case CANDLE_INTERVAL_DAY
    }
}
