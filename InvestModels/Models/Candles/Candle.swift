/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

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
    public let o : Double?
    public let c : Double?
    public let h : Double?
    public let l : Double?
    public let v : Int?
    public let time : Date?

	enum CodingKeys: String, CodingKey {

		case figi = "figi"
		case interval = "interval"
		case o = "o"
		case c = "c"
		case h = "h"
		case l = "l"
		case v = "v"
		case time = "time"
	}

    public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		figi = try values.decodeIfPresent(forKey: .figi)
		interval = try values.decodeIfPresent(forKey: .interval)
		o = try values.decodeIfPresent(forKey: .o)
		c = try values.decodeIfPresent(forKey: .c)
		h = try values.decodeIfPresent(forKey: .h)
		l = try values.decodeIfPresent(forKey: .l)
		v = try values.decodeIfPresent(forKey: .v)
		time = try values.decodeIfPresent(forKey: .time)
	}

}
