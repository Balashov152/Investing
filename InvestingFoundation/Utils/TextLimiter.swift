//
//  TextLimiter.swift
//  Investing
//
//  Created by Sergey Balashov on 12.02.2021.
//

import Combine
import Foundation
import SwiftUI

class TextLimiter: ObservableObject {
    private let limit: Int

    @Published var hasReachedLimit = false
    @Published var value = "" {
        didSet {
            if value.count > limit {
                value = String(value.prefix(limit))
            }
            hasReachedLimit = value.count > limit
        }
    }

    init(limit: Int) {
        self.limit = limit
    }
}
