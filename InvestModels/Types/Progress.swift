//
//  Progress.swift
//  InvestModels
//
//  Created by Sergey Balashov on 21.02.2023.
//

import Foundation

public struct LoadingProgress {
    public let current: Int
    public let all: Int
    
    public init(current: Int, all: Int) {
        self.current = current
        self.all = all
    }
}
