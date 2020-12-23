/* 
Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation

extension Position: Hashable {
    public static func == (lhs: Position, rhs: Position) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ticker)
    }
}

public struct Position: Decodable {
    public let name: String?
    public let figi: String?
    public let ticker: String?

    public let isin: String?
    public let instrumentType: InstrumentType?

    public let balance: Double?
    public let blocked: Double?

    public let lots: Int?

    public let expectedYield: MoneyAmount?
    public let averagePositionPrice: MoneyAmount?
    public let averagePositionPriceNoNkd: MoneyAmount?

    public var totalBuyPayment: Double {
        (averagePositionPrice?.value ?? 0) * Double(lots ?? 0)
    }

    public var totalInProfile: Double {
        totalBuyPayment + (expectedYield?.value ?? 0)
    }

    public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		figi = try values.decodeIfPresent(forKey: .figi)
		ticker = try values.decodeIfPresent(forKey: .ticker)
		isin = try values.decodeIfPresent(forKey: .isin)
		instrumentType = try values.decodeIfPresent(forKey: .instrumentType)
		balance = try values.decodeIfPresent(forKey: .balance)
		blocked = try values.decodeIfPresent(forKey: .blocked)
		expectedYield = try values.decodeIfPresent(forKey: .expectedYield)
		lots = try values.decodeIfPresent(forKey: .lots)
		averagePositionPrice = try values.decodeIfPresent(forKey: .averagePositionPrice)
		averagePositionPriceNoNkd = try values.decodeIfPresent(forKey: .averagePositionPriceNoNkd)
		name = try values.decodeIfPresent(forKey: .name)
	}

    public enum CodingKeys: String, CodingKey {

        case figi = "figi"
        case ticker = "ticker"
        case isin = "isin"
        case instrumentType = "instrumentType"
        case balance = "balance"
        case blocked = "blocked"
        case expectedYield = "expectedYield"
        case lots = "lots"
        case averagePositionPrice = "averagePositionPrice"
        case averagePositionPriceNoNkd = "averagePositionPriceNoNkd"
        case name = "name"
    }

}
