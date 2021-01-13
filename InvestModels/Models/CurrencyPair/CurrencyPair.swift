//
//  CurrencyPair.swift
//  InvestModels
//
//  Created by Sergey Balashov on 25.12.2020.
//

import Foundation
public extension CurrencyPair {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
}

public struct CurrencyPair: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(USD)
        hasher.combine(EUR)
    }
    
    public let date: Date
    public let USD: Double
    public let EUR: Double
    
    public init(date: Date, USD: Double, EUR: Double) {
        self.date = date
        self.USD = USD
        self.EUR = EUR
    }
    
    public init(currencyPairR: CurrencyPairR) {
        self.date = currencyPairR.date
        self.USD = currencyPairR.USD
        self.EUR = currencyPairR.EUR
    }
}