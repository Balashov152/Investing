import Foundation

public extension Candle {
    enum Interval: String, Codable {
        case onemin = "1min"
        case twomin = "2min"
        case thereemin = "3min"
        case fivemin = "5min"
        case tenmin = "10min"
        case fiftenmin = "15min"
        case thertymin = "30min"
        case hour, day, week, month
    }
}

public struct Candle : Codable {
    public let figi : String?
    public let interval : Interval?
    public let open : Double
    public let close : Double
    public let high : Double
    public let low : Double
    public let v : Int?
    public let time : Date?

	enum CodingKeys: String, CodingKey {
		case figi = "figi"
		case interval = "interval"
		case open = "o"
		case close = "c"
		case high = "h"
		case low = "l"
		case v = "v"
		case time = "time"
	}

    public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		figi = try values.decodeIfPresent(forKey: .figi)
		interval = try values.decodeIfPresent(forKey: .interval)
		open = try values.decodeIfPresent(forKey: .open, default: 0)
		close = try values.decodeIfPresent(forKey: .close, default: 0)
		high = try values.decodeIfPresent(forKey: .high, default: 0)
		low = try values.decodeIfPresent(forKey: .low, default: 0)
		v = try values.decodeIfPresent(forKey: .v)
		time = try values.decodeIfPresent(forKey: .time)
	}

}
