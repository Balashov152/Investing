//
//  MoneyAmount+Ex.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Foundation
import InvestModels

extension Collection where Element == MoneyAmount {
    var sum: Double {
        map { $0.value }.sum
    }
}
