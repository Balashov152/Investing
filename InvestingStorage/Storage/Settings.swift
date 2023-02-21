//
//  Settings.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Foundation
import InvestModels

public struct Settings {
    public static var shared = Settings()

    @UserDefault(key: .isSandbox, defaultValue: false)
    public var isSandbox: Bool

    // MARK: Settings

    @UserDefault(key: .currency, defaultValue: nil)
    public var currency: Price.Currency?

    @UserDefault(key: .dateInterval, defaultValue: .from2020ToNow)
    public var dateInterval: InvestModels.DateInterval

    @UserDefault(key: .adjustedAverage, defaultValue: true)
    public var adjustedAverage: Bool

    @UserDefault(key: .adjustedTotal, defaultValue: false)
    public var adjustedTotal: Bool

    @UserDefault(key: .minusDebt, defaultValue: false)
    public var minusDebt: Bool

    // MARK: Home

    @UserDefault(key: .expandedHome, defaultValue: [])
    public var expandedHome: Set<InstrumentType>

    // MARK: Currency

    @UserDefault(key: .averageCurrency, defaultValue: [:])
    public var averageCurrency: [Currency: Double]

    // MARK: Blocked

    @UserDefault(key: .blockedPosition, defaultValue: [:])
    public var blockedPosition: [String: MoneyAmount]

    // MARK: Target

    @UserDefault(key: .targetPositions, defaultValue: [:])
    public var targetPositions: [String: Double]

    @UserDefault(key: .targetDate, defaultValue: Date().years(value: 1))
    public var targetDate: Date

    @UserDefault(key: .targetTotalPortfolio, defaultValue: nil)
    public var targetTotalPortfolio: MoneyAmount?
}
