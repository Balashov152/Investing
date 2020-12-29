//
//  CurrencyConvertModel.swift
//  InvestModels
//
//  Created by Sergey Balashov on 25.12.2020.
//

import Foundation

public protocol CurrencyConvertModel {
    var currencyPair: CurrencyPair? { get }
    
    func convert(money: MoneyAmount, to currency: Currency) -> MoneyAmount
}

public extension CurrencyConvertModel {
    func convert(money: MoneyAmount, to currency: Currency) -> MoneyAmount {
        guard let currencyPair = currencyPair else {
//            assertionFailure("currencyPair is nil")
            return money
        }
        
        guard money.currency != currency else {
            debugPrint("convert same currenses (\(money.currency)) -> (\(currency))")
            return money
        }
        
        switch (money.currency, currency) {
        case (.RUB, .USD): // RUB -> USD
            let newValue = money.value * currencyPair.USD
            debugPrint("RUB(\(money.value)) -> USD(\(newValue))")
            return MoneyAmount(currency: currency, value: newValue)
        case (.USD, .RUB):  // USD -> RUB
            let newValue = money.value / currencyPair.USD
            debugPrint("USD(\(money.value)) -> RUB(\(newValue))")
            return MoneyAmount(currency: currency, value: newValue)
        default:
            assertionFailure("not implement case \((money.currency, currency))")
            return money
        }
    }
}
