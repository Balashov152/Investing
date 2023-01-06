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

    @UserDefault(key: .isSandbox, defaultValue: false)
    var isSandbox: Bool

    // MARK: Settings

    @UserDefault(key: .currency, defaultValue: nil)
    var currency: Currency?

    @UserDefault(key: .dateInterval, defaultValue: .from2020ToNow)
    var dateInterval: DateInterval

    @UserDefault(key: .adjustedAverage, defaultValue: true)
    var adjustedAverage: Bool

    @UserDefault(key: .adjustedTotal, defaultValue: false)
    var adjustedTotal: Bool

    @UserDefault(key: .minusDebt, defaultValue: false)
    var minusDebt: Bool

    // MARK: Home

    @UserDefault(key: .expandedHome, defaultValue: [])
    var expandedHome: Set<InstrumentType>

    @UserDefault(key: .homeSortType, defaultValue: .profit)
    var homeSortType: HomeViewModel.SortType

    // MARK: Currency

    @UserDefault(key: .averageCurrency, defaultValue: [:])
    var averageCurrency: [Currency: Double]

    // MARK: Blocked

    @UserDefault(key: .blockedPosition, defaultValue: [:])
    var blockedPosition: [String: MoneyAmount]

    // MARK: Target

    @UserDefault(key: .targetPositions, defaultValue: [:])
    var targetPositions: [String: Double]

    @UserDefault(key: .targetDate, defaultValue: Date().years(value: 1))
    var targetDate: Date

    @UserDefault(key: .targetTotalPortfolio, defaultValue: nil)
    var targetTotalPortfolio: MoneyAmount?
}
