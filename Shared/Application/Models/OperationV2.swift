//
//  OperationV2.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2022.
//

import Foundation

struct OperationV2: Codable {
    let id: String?
    let date: Date?
    let instrumentType: String?
    let quantity: String?
    let parentOperationId: String?
    let figi: String?
    let type: String?
    let price: Price?
    let currency: String?
    let payment: Price?
    let quantityRest: String?
    let operationType: OperationType?
}

extension OperationV2 {
    init(realmOperation: RealmOperation) {
        id = realmOperation.id
        date = realmOperation.date
        instrumentType = realmOperation.instrumentType
        operationType = OperationType(rawValue: realmOperation.instrumentType ?? "")
        quantity = realmOperation.quantity
        parentOperationId = realmOperation.parentOperationId
        figi = realmOperation.figi
        type = realmOperation.type
        price = realmOperation.price.map(Price.init)
        currency = realmOperation.currency
        payment = realmOperation.payment.map(Price.init)
        quantityRest = realmOperation.quantityRest
    }
}

extension OperationV2 {
    enum OperationType: String, Codable {
        case OPERATION_TYPE_UNSPECIFIED
        case OPERATION_TYPE_INPUT
        case OPERATION_TYPE_BOND_TAX
        case OPERATION_TYPE_OUTPUT_SECURITIES
        case OPERATION_TYPE_OVERNIGHT
        case OPERATION_TYPE_TAX
        case OPERATION_TYPE_BOND_REPAYMENT_FULL
        case OPERATION_TYPE_SELL_CARD
        case OPERATION_TYPE_DIVIDEND_TAX
        case OPERATION_TYPE_OUTPUT
        case OPERATION_TYPE_BOND_REPAYMENT
        case OPERATION_TYPE_TAX_CORRECTION
        case OPERATION_TYPE_SERVICE_FEE
        case OPERATION_TYPE_BENEFIT_TAX
        case OPERATION_TYPE_MARGIN_FEE
        case OPERATION_TYPE_BUY
        case OPERATION_TYPE_BUY_CARD
        case OPERATION_TYPE_INPUT_SECURITIES
        case OPERATION_TYPE_SELL_MARJIN
        case OPERATION_TYPE_BROKER_FEE
        case OPERATION_TYPE_BUY_MARGIN
        case OPERATION_TYPE_DIVIDEND
        case OPERATION_TYPE_SELL
        case OPERATION_TYPE_COUPON
        case OPERATION_TYPE_SUCCESS_FEE
        case OPERATION_TYPE_DIVIDEND_TRANSFER
        case OPERATION_TYPE_ACCRUING_VARMARJIN
        case OPERATION_TYPE_WRITING_OFF_VARMARJIN
        case OPERATION_TYPE_DELIVERY_BUY
        case OPERATION_TYPE_DELIVERY_SELL
        case OPERATION_TYPE_TRACK_MFEE
        case OPERATION_TYPE_TRACK_PFEE
        case OPERATION_TYPE_TAX_PROGRESSIVE
        case OPERATION_TYPE_BOND_TAX_PROGRESSIVE
        case OPERATION_TYPE_DIVIDEND_TAX_PROGRESSIVE
        case OPERATION_TYPE_BENEFIT_TAX_PROGRESSIVE
        case OPERATION_TYPE_TAX_CORRECTION_PROGRESSIVE
        case OPERATION_TYPE_TAX_REPO_PROGRESSIVE
        case OPERATION_TYPE_TAX_REPO
        case OPERATION_TYPE_TAX_REPO_HOLD
        case OPERATION_TYPE_TAX_REPO_REFUND
        case OPERATION_TYPE_TAX_REPO_HOLD_PROGRESSIVE
        case OPERATION_TYPE_TAX_REPO_REFUND_PROGRESSIVE
        case OPERATION_TYPE_DIV_EXT
    }
}
