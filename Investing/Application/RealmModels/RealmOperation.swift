//
//  RealmOperation.swift
//  Investing
//
//  Created by Sergey Balashov on 27.01.2022.
//

import Foundation
import RealmSwift

public class RealmOperation: Object {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var date: Date?
    @Persisted var instrumentType: String?
    @Persisted var operationType: String?
    @Persisted var state: String = ""
    @Persisted var quantity: String?
    @Persisted var parentOperationId: String?
    @Persisted var figi: String?
    @Persisted var type: String?
    @Persisted var price: RealmPrice?
    @Persisted var currency: String = ""
    @Persisted var payment: RealmPrice?
    @Persisted var quantityRest: String?

    @Persisted var share: RealmShare?
}

extension RealmOperation {
    static func realmOperation(from operation: OperationV2) -> RealmOperation {
        let realmOperation = RealmOperation()
        realmOperation.id = operation.id
        realmOperation.date = operation.date
        realmOperation.instrumentType = operation.instrumentType?.rawValue
        realmOperation.operationType = operation.operationType?.rawValue
        realmOperation.state = operation.state.rawValue
        realmOperation.quantity = operation.quantity
        realmOperation.parentOperationId = operation.parentOperationId
        realmOperation.figi = operation.figi
        realmOperation.type = operation.type
        realmOperation.price = operation.price.map(RealmPrice.realmPrice)
        realmOperation.currency = operation.currency.rawValue
        realmOperation.payment = operation.payment.map(RealmPrice.realmPrice)
        realmOperation.quantityRest = operation.quantityRest

        return realmOperation
    }
}
