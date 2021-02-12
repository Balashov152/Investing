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

    var percent: Double {
        (expectedProfile.value / totalInProfile.value) * 100
    }
}
