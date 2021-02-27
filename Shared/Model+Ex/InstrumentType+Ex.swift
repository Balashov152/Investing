//
//  InstrumentType+Ex.swift
//  Investing
//
//  Created by Sergey Balashov on 27.02.2021.
//

import Foundation
import InvestModels

extension InstrumentType {
    var pluralName: String {
        switch self {
        case .Bond, .Stock, .Etf:
            return (rawValue + "s").localized
        case .Currency:
            return "Currencies".localized
        }
    }
}
