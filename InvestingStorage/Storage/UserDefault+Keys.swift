//
//  UserDefault+Keys.swift
//  InvestingFoundation
//
//  Created by Sergey Balashov on 21.02.2023.
//

import Foundation

extension UserDefault {
    enum ClearKeys: String, CaseIterable {
        case token, newToken, currency
        case dateInterval
        case payInAvg, expandedHome
        case adjustedAverage
        case adjustedTotal
        case averageCurrency
        case minusDebt
        case homeSortType
        case targetDate
        case targetTotalPortfolio
        case blockedPosition
        case targetPositions
    }

    enum StorageKeys: String {
        case currentDBVersion
        case isSandbox
    }
}
