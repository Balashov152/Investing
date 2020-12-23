//
//  CurrencyPair.swift
//  InvestModels
//
//  Created by Sergey Balashov on 22.12.2020.
//

import Foundation
import RealmSwift
import Realm

open class CurrencyPair: Object {
    @objc public dynamic var id: String? = nil
    @objc public dynamic var date: Date = Date()
    @objc public dynamic var USD: Double = 0.0
    @objc public dynamic var EUR: Double = 0.0
    
    open override class func primaryKey() -> String? {
        return "id"
    }
    
    public func fill(date: Date, USD: Double, EUR: Double) {
        self.id = date.description
        self.date = date
        self.USD = USD
        self.EUR = EUR
    }
}
