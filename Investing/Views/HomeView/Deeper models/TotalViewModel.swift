//
//  TotalViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 12.02.2021.
//

import Foundation
import InvestModels
import SwiftUI

protocol TotalViewModeble {
    var totalInProfile: MoneyAmount { get }
    var blocked: MoneyAmount? { get }
    var expectedProfile: MoneyAmount { get }
    var percent: Double { get }
}

struct TotalViewModel: TotalViewModeble {
    let currency: Currency
    let positions: [Position]

    var filteredPositions: [Position] {
        positions.filter { $0.currency == currency }
    }

    var totalInProfile: MoneyAmount {
        MoneyAmount(currency: currency, value: filteredPositions.map { $0.totalInProfile }.sum)
    }

    var expectedProfile: MoneyAmount {
        MoneyAmount(currency: currency, value: filteredPositions.map { $0.expectedYield }.sum)
    }

    var blocked: MoneyAmount? {
        let sum = filteredPositions.compactMap { $0.blocked }.sum
        if sum > 0 {
            return MoneyAmount(currency: currency, value: sum)
        }

        return nil
    }

    var percent: Double {
        (expectedProfile.value / totalInProfile.value) * 100
    }
}
