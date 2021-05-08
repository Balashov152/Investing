//
//  PayInPlan.swift
//  InvestModels
//
//  Created by Sergey Balashov on 08.05.2021.
//

import Foundation

public extension PayInPlan {
    enum OfftenType: String, Hashable, CaseIterable {
        case day, week, month
    }
}

public struct PayInPlan: Hashable {
    public let offtenType: OfftenType
    public let money: Double
    
    public init(offtenType: OfftenType, money: Double) {
        self.offtenType = offtenType
        self.money = money
    }
    
    public init(payInPlanR: PayInPlanR) {
        self.offtenType = .init(rawValue: payInPlanR.offtenTypeRaw) ?? .week
        self.money = payInPlanR.money
    }
}
