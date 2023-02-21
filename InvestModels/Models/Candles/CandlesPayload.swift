import Foundation

public struct CandlesPayload : Codable {
    public let figi : String?
    public let interval : Candle.Interval?
    public let candles : [Candle]

	enum CodingKeys: String, CodingKey {
		case figi = "figi"
		case interval = "interval"
		case candles = "candles"
	}

    public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		figi = try values.decodeIfPresent(forKey: .figi)
		interval = try values.decodeIfPresent(forKey: .interval)
        candles =  try values.decodeIfPresent(forKey: .candles, default: [])
	}
}
