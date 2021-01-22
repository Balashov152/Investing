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

public struct CurrencyConvertManager {
    public static func convert(currencyPair: CurrencyPair?,
                        money: MoneyAmount, to currency: Currency) -> MoneyAmount {
        guard let currencyPair = currencyPair else {
            debugPrint("currencyPair is nil")
            return money
        }
        
        guard money.currency != currency else {
            return money
        }
        
        switch (money.currency, currency) {
        case (.RUB, .USD): // RUB -> USD
            let newValue = money.value * currencyPair.USD
//            debugPrint("RUB(\(money.value)) -> USD(\(newValue))")
            return MoneyAmount(currency: currency, value: newValue)
        case (.USD, .RUB):  // USD -> RUB
            let newValue = money.value / currencyPair.USD
//            debugPrint("USD(\(money.value)) -> RUB(\(newValue))")
            return MoneyAmount(currency: currency, value: newValue)
        case (.RUB, .EUR):
            let newValue = money.value * currencyPair.EUR
//            debugPrint("RUB(\(money.value)) -> EUR(\(newValue))")
            return MoneyAmount(currency: currency, value: newValue)
        case (.EUR, .RUB):
            let newValue = money.value / currencyPair.EUR
//            debugPrint("EUR(\(money.value)) -> RUB(\(newValue))")
            return MoneyAmount(currency: currency, value: newValue)
        case (.USD, .EUR):
            let newValue = money.value / currencyPair.USD * currencyPair.EUR
//            debugPrint("USD(\(money.value)) -> EUR(\(newValue))")
            return MoneyAmount(currency: currency, value: newValue)
        case (.EUR, .USD):
            let newValue = money.value / currencyPair.EUR * currencyPair.USD
//            debugPrint("EUR(\(money.value)) -> USD(\(newValue))")
            return MoneyAmount(currency: currency, value: newValue)
        default:
            assertionFailure("not implement case \((money.currency, currency))")
            return money
        }
    }
}

public extension CurrencyConvertModel {
    func convert(money: MoneyAmount, to currency: Currency) -> MoneyAmount {
        CurrencyConvertManager.convert(currencyPair: currencyPair, money: money, to: currency)
    }
}

public extension CurrencyConvertModel where Self == Operation {
    func convertPayment(to cur: Currency) -> MoneyAmount {
        convert(money: MoneyAmount(currency: self.currency, value: self.payment), to: cur)
    }
}
