//
//  Settings.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Foundation
import InvestModels

struct Settings {
    static var shared = Settings()

    @UserDefault(key: .expandedHome, defaultValue: [])
    var expandedHome: Set<InstrumentType>

    @UserDefault(key: .currency, defaultValue: nil)
    var currency: Currency?

    @UserDefault(key: .dateInterval, defaultValue: .lastYear)
    var dateInterval: DateInterval

    @UserDefault(key: .adjustedAverage, defaultValue: false)
    var adjustedAverage: Bool

    @UserDefault(key: .averageCurrency, defaultValue: [:])
    var averageCurrency: [Currency: Double]

    @UserDefault(key: .averageCurrency, defaultValue: .profit)
    var homeSortType: HomeViewModel.SortType
}
