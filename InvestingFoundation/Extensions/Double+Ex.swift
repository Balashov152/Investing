//
//  Double+Ex.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Foundation

public extension Collection where Element == Double {
    var sum: Double {
        reduce(0, +)
    }
}
