//
//  OperationSum.swift
//  Investing
//
//  Created by Sergey Balashov on 21.12.2020.
//

import Foundation
import InvestModels

extension Collection where Element == Operation {
    var sum: Double {
        map { $0.payment }.reduce(0, +)
    }
}

extension Collection where Element == MoneyAmount {
    var sum: Double {
        map { $0.value }.reduce(0, +)
    }
}

extension Collection where Element == Double {
    var sum: Double {
        reduce(0, +)
    }
}

extension DateFormatter {
    
    static func format(_ string: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = string
        return formatter
    }
    
}
