//
//  PayInPlanR.swift
//  InvestModels
//
//  Created by Sergey Balashov on 08.05.2021.
//

import Foundation
import RealmSwift
import Realm

open class PayInPlanR: Object {
    @objc public dynamic var id: String = UUID().uuidString
    @objc public dynamic var offtenTypeRaw: String = PayInPlan.OfftenType.week.rawValue
    @objc public dynamic var money: Double = 0.0
    
    open override class func primaryKey() -> String? {
        return "id"
    }
    
    public init(payInPlan: PayInPlan) {
        self.id = payInPlan.offtenType.rawValue + String(payInPlan.money)
        self.offtenTypeRaw = payInPlan.offtenType.rawValue
        self.money = payInPlan.money
        
        super.init()
    }
    
    public override init() {
        super.init()
    }
}
