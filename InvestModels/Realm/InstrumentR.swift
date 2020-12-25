//
//  InstrumentR.swift
//  InvestModels
//
//  Created by Sergey Balashov on 24.12.2020.
//

import Foundation
import RealmSwift

open class InstrumentR: Object, Decodable {
    open override class func primaryKey() -> String? {
        return "figi"
    }
    
    @objc public dynamic var name: String = ""
    @objc public dynamic var ticker: String = ""
    
    @objc public dynamic var figi: String = ""
    @objc public dynamic var isin: String = ""
    
    @objc public dynamic var minQuantity: Int = 1
    @objc public dynamic var minPriceIncrement: Double = 0.01
    @objc public dynamic var lot: Int = 1
    
    @objc public dynamic var currencyRaw: String = Instrument.defaultCurrency.rawValue
    @objc public dynamic var typeRaw: String = Instrument.defaultInstrument.rawValue
    
    public override init() {
        super.init()
    }
    
    public init(instrument: Instrument) {
        self.name = instrument.name
        self.ticker = instrument.ticker
        self.figi = instrument.figi
        self.isin = instrument.isin
        self.minQuantity = instrument.minQuantity
        self.minPriceIncrement = instrument.minPriceIncrement
        self.lot = instrument.lot
        self.currencyRaw = instrument.currency.rawValue
        self.typeRaw = instrument.type.rawValue
        
        super.init()
    }
}
