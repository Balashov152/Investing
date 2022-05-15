//
//  Candle+Ex.swift
//  Investing
//
//  Created by Sergey Balashov on 15.04.2021.
//

import Foundation
import InvestModels

extension Candle {
    var avg: Double {
        (low + high) / 2
    }
}
