/* 
Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import InvestingFoundation

extension Instrument {
    static let defaultCurrency = Currency.USD
    static let defaultInstrument = InstrumentType.Stock
}

extension Instrument: Hashable {
    public static func == (lhs: Instrument, rhs: Instrument) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(figi)
        hasher.combine(ticker)
    }
}

extension String {
    static let empty: String = ""
}

public struct Instrument: Decodable {
    public let name: String
    public let ticker: String

    public let figi: String
    public let isin: String

    public let minQuantity: Int
    public let minPriceIncrement: Double
    public let lot: Int
    
    public let currency: Currency
    public let type: InstrumentType
    
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
        name = try values.decodeIfPresent(forKey: .name, default: .empty)
        figi = try values.decodeIfPresent(forKey: .figi, default: .empty)
		ticker = try values.decodeIfPresent(forKey: .ticker, default: .empty)
		isin = try values.decodeIfPresent(forKey: .isin, default: .empty)
        
        minPriceIncrement = try values.decodeIfPresent(forKey: .minPriceIncrement, default: 0.01)
		lot = try values.decodeIfPresent(forKey: .lot, default: 1)
		minQuantity = try values.decodeIfPresent(forKey: .minQuantity, default: 1)
        
        currency = try values.decodeIfPresent(forKey: .currency, default: Instrument.defaultCurrency)
        type = try values.decodeIfPresent(forKey: .type, default: Instrument.defaultInstrument)
	}
    
    public init(instrument: InstrumentR) {
        self.name = instrument.name
        self.ticker = instrument.ticker
        self.figi = instrument.figi
        self.isin = instrument.isin
        self.minQuantity = instrument.minQuantity
        self.minPriceIncrement = instrument.minPriceIncrement
        self.lot = instrument.lot
        self.currency = Currency(rawValue: instrument.currencyRaw) ?? Instrument.defaultCurrency
        self.type = InstrumentType(rawValue: instrument.typeRaw) ?? Instrument.defaultInstrument
    }
}
