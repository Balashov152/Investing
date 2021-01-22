//
//  PinnedInstrumentR.swift
//  InvestModels
//
//  Created by Sergey Balashov on 22.01.2021.
//

import Foundation
import RealmSwift

open class PinnedInstrumentR: Object, Decodable {
    open override class func primaryKey() -> String? {
        return "figi"
    }
    
    @objc public dynamic var ticker: String = ""
    @objc public dynamic var figi: String = ""
    
    public override init() {
        super.init()
    }
    
    public init(instrument: Instrument) {
        self.ticker = instrument.ticker
        self.figi = instrument.figi

        super.init()
    }
}
