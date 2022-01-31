/* 
Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation

public extension Double {
    func addCurrency(_ currency: Currency) -> MoneyAmount {
        .init(currency: currency, value: self)
    }
}

public extension MoneyAmount {
    static func + (lhs: MoneyAmount, rhs: MoneyAmount) -> MoneyAmount {
        MoneyAmount(currency: lhs.currency, value: lhs.value + rhs.value)
    }

    static func - (lhs: MoneyAmount, rhs: MoneyAmount) -> MoneyAmount {
        MoneyAmount(currency: lhs.currency, value: lhs.value - rhs.value)
    }
    
    static func / (lhs: MoneyAmount, rhs: MoneyAmount) -> MoneyAmount {
        MoneyAmount(currency: lhs.currency, value: lhs.value / rhs.value)
    }
}

public struct MoneyAmount: Codable, Hashable {
    public let currency: Currency
    public let value: Double
    
    public init(currency: Currency, value: Double) {
        self.currency = currency
        self.value = value
    }

    public enum CodingKeys: String, CodingKey {
		case currency = "currency"
		case value = "value"
	}

    public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
        currency = try values.decodeIfPresent(forKey: .currency, default: .USD)
        value = try values.decodeIfPresent(forKey: .value, default: 0)
	}
    
    public static var zero: MoneyAmount {
        MoneyAmount(currency: .USD, value: 0)
    }
}
