/* 
Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
import RealmSwift

open class Instrument: Object, Decodable {
    static let defaultCurrency = Currency.USD
    static let defaultInstrument = InstrumentType.Stock
    
    @objc public dynamic var name: String?
    @objc public dynamic var ticker: String?
    
    @objc public dynamic var figi: String?
    @objc public dynamic var isin: String?
    
    @objc public dynamic var minQuantity: Int = 1
    @objc public dynamic var minPriceIncrement: Double = 0.01
    @objc public dynamic var lot: Int = 1
    
    @objc public dynamic var currencyRaw: String = Instrument.defaultCurrency.rawValue
    @objc public dynamic var typeRaw: String = Instrument.defaultInstrument.rawValue
    
    open override class func primaryKey() -> String? {
        return "figi"
    }
    
    public var currency: Currency {
        get { Currency(rawValue: currencyRaw) ?? Instrument.defaultCurrency }
        set { currencyRaw = newValue.rawValue }
    }
    
   public var type: InstrumentType {
        get { InstrumentType(rawValue: typeRaw) ?? Instrument.defaultInstrument }
        set { typeRaw = newValue.rawValue }
    }
    
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
    
    public override init() {
        super.init()
    }

    required public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		figi = try values.decodeIfPresent(forKey: .figi)
		ticker = try values.decodeIfPresent(forKey: .ticker)
		isin = try values.decodeIfPresent(forKey: .isin)
        minPriceIncrement = try values.decodeIfPresent(forKey: .minPriceIncrement, default: 0.01)
		lot = try values.decodeIfPresent(forKey: .lot, default: 1)
		minQuantity = try values.decodeIfPresent(forKey: .minQuantity, default: 1)
        
		name = try values.decodeIfPresent(forKey: .name)
        
        currencyRaw = try values.decodeIfPresent(forKey: .currency, default: Instrument.defaultCurrency.rawValue)
        typeRaw = try values.decodeIfPresent(forKey: .type, default: Instrument.defaultInstrument.rawValue)
	}
    
    // Hashable
    
//    public static func == (lhs: Instrument, rhs: Instrument) -> Bool {
//        lhs.hashValue == rhs.hashValue
//    }
    
//    public override func hash(into hasher: inout Hasher) {
//        hasher.combine(figi)
//        hasher.combine(ticker)
//    }

}
