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
    @Persisted public var date: Date?
    @Persisted public var instrumentType: String?
    @Persisted public var operationType: String?
    @Persisted public var state: String = ""
    @Persisted public var quantity: String?
    @Persisted public var parentOperationId: String?
    @Persisted public var figi: String?
    @Persisted public var type: String?
    @Persisted public var price: RealmPrice?
    @Persisted public var currency: String = ""
    @Persisted public var payment: RealmPrice?
    @Persisted public var quantityRest: String?

    @Persisted public var share: RealmShare?
}

public extension RealmOperation {
    public static func realmOperation(from operation: OperationV2) -> RealmOperation {
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
