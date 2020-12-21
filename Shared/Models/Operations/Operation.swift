/* 
 Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar
 
 */

import Foundation

extension Operation: Hashable {
    static func == (lhs: Operation, rhs: Operation) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Operation : Decodable {
    let id : String?
    
    let status : OperationStatus?
    enum OperationStatus: String, Decodable {
        case Done, Decline, Progress
    }
    
    let trades : [Trades]
    var tradersCount: Int {
        trades.compactMap { $0.quantity }.reduce(0, +)
    }
    var changeCount: Int {
        Int(payment)
    }
    let commission : MoneyAmount?
    
    let currency : Currency
    let payment : Double
    
    let price : Double?
    
    let quantity : Int
    let quantityExecuted : Int
    
    let figi : String?
    var instument: Instrument?
    let instrumentType : InstrumentType?
    
    let isMarginCall : Bool
    let date : Date
    let operationType : OperationTypeWithCommission?
    
    enum OperationTypeWithCommission: String, Decodable, CaseIterable {
        case Buy, BuyCard, Sell
        case BrokerCommission, ExchangeCommission, ServiceCommission, MarginCommission, OtherCommission
        case PayIn, PayOut
        case Tax, TaxLucre, TaxDividend, TaxCoupon, TaxBack
        case Repayment, PartRepayment
        case Coupon, Dividend, SecurityIn, SecurityOut
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case status = "status"
        case trades = "trades"
        case commission = "commission"
        case currency = "currency"
        case payment = "payment"
        case price = "price"
        case quantity = "quantity"
        case quantityExecuted = "quantityExecuted"
        case figi = "figi"
        case instrumentType = "instrumentType"
        case isMarginCall = "isMarginCall"
        case date = "date"
        case operationType = "operationType"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(forKey: .id)
        status = try values.decodeIfPresent(forKey: .status)
        trades = try values.decodeIfPresent(forKey: .trades, default: [])
        commission = try values.decodeIfPresent(forKey: .commission)
        currency = try values.decodeIfPresent(forKey: .currency, default: .USD)
        payment = try values.decodeIfPresent(forKey: .payment, default: 0)
        price = try values.decodeIfPresent(forKey: .price)
        quantity = try values.decodeIfPresent(forKey: .quantity, default: 0)
        quantityExecuted = try values.decodeIfPresent(forKey: .quantityExecuted, default: 0)
        figi = try values.decodeIfPresent(forKey: .figi)
        instrumentType = try values.decodeIfPresent(forKey: .instrumentType)
        isMarginCall = try values.decodeIfPresent(forKey: .isMarginCall, default: false)
        date = try values.decodeIfPresent(forKey: .date, default: Date())
        operationType = try values.decodeIfPresent(forKey: .operationType)
    }
    
}
