/* 
Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation

extension Instrument: Hashable {
    public static func == (lhs: Instrument, rhs: Instrument) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(figi)
        hasher.combine(ticker)
    }
}

public struct Instrument: Codable {
    public let figi: String?
    public let ticker: String?
    public let isin: String?
    public let minPriceIncrement: Double?
    public let lot: Int?
    public let minQuantity: Int?
    public let currency: Currency
    public let name: String?
    public let type: InstrumentType?

    public enum CodingKeys: String, CodingKey {
		case figi = "figi"
		case ticker = "ticker"
		case isin = "isin"
		case minPriceIncrement = "minPriceIncrement"
		case lot = "lot"
		case minQuantity = "minQuantity"
		case currency = "currency"
		case name = "name"
		case type = "type"
	}

    public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		figi = try values.decodeIfPresent(forKey: .figi)
		ticker = try values.decodeIfPresent(forKey: .ticker)
		isin = try values.decodeIfPresent(forKey: .isin)
		minPriceIncrement = try values.decodeIfPresent(forKey: .minPriceIncrement)
		lot = try values.decodeIfPresent(forKey: .lot)
		minQuantity = try values.decodeIfPresent(forKey: .minQuantity)
        currency = try values.decodeIfPresent(forKey: .currency, default: .TRY)
		name = try values.decodeIfPresent(forKey: .name)
		type = try values.decodeIfPresent(forKey: .type)
	}

}
