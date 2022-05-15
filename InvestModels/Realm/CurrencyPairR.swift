//
//  CurrencyPair.swift
//  InvestModels
//
//  Created by Sergey Balashov on 22.12.2020.
//

import Foundation
import RealmSwift

open class CurrencyPairR: Object {
    @objc public dynamic var id: String = UUID().uuidString
    @objc public dynamic var date: Date = Date()
    @objc public dynamic var USD: Double = 0.0
    @objc public dynamic var EUR: Double = 0.0
    
    open override class func primaryKey() -> String? {
        return "id"
    }
    
    public init(currencyPair: CurrencyPair) {
        self.id = CurrencyPair.dateFormatter.string(from: currencyPair.date)
        self.date = currencyPair.date
        self.USD = currencyPair.USD
        self.EUR = currencyPair.EUR
        
        super.init()
    }
    
    public override init() {
        super.init()
    }
}
