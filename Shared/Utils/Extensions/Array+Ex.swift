//
//  Array+Ex.swift
//  Investing
//
//  Created by Sergey Balashov on 15.01.2021.
//

import Foundation

extension Array where Element: Hashable {
    var unique: [Element] {
        Array(Set(self))
    }
}

extension Collection {
    func enumeratedArray() -> [(offset: Int, element: Self.Element)] {
        return Array(enumerated())
    }
}
