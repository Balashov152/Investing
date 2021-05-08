//
//  Identifiable+Ex.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Foundation

public extension Identifiable where Self: Hashable {
    var id: Int { hashValue }
}
