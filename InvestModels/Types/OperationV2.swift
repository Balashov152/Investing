//
//  OperationV2.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2022.
//

import Foundation

extension OperationV2: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public class OperationV2: Decodable {
    /// Идентификатор операции
    public let id: String
    public let date: Date
    public let instrumentType: InstrumentTypeV2?

    /// Идентификатор родительской операции
    public let parentOperationId: String?
    /// Figi-идентификатор инструмента, связанного с операцией
    public let figi: String?
    public let type: String?
    /// Цена операции
    public let price: Price?
    /// Валюта операции
    public let currency: Price.Currency

    /// Сумма операции
    public let payment: Price?

    /// Количество лотов инструмента
    public let quantity: String?

    /// Неисполненный остаток по сделке
    public let quantityRest: String?

    public let operationType: OperationType?
    public let state: OperationState

    // FILL FROM DB
    public var share: Share?

    public init(
        id: String?,
        date: Date,
        instrumentType: InstrumentTypeV2?,
        quantity: String?,
        parentOperationId: String?,
        figi: String?,
        type: String?,
        price: Price?,
        currency: Price.Currency,
        payment: Price?,
        quantityRest: String?,
        operationType: OperationV2.OperationType?,
        state: OperationState,
        share: Share? = nil
    ) {
        self.id = id!
        self.date = date
        self.instrumentType = instrumentType
        self.quantity = quantity
        self.parentOperationId = parentOperationId
        self.figi = figi
        self.type = type
        self.price = price
        self.currency = currency
        self.payment = payment
        self.quantityRest = quantityRest
        self.operationType = operationType
        self.state = state
        self.share = share
    }

    public init(realmOperation: RealmOperation) {
        id = realmOperation.id
        date = realmOperation.date ?? Date()
        instrumentType = InstrumentTypeV2(rawValue: realmOperation.instrumentType ?? "")
        operationType = OperationType(rawValue: realmOperation.operationType ?? "")
        state = OperationState(rawValue: realmOperation.state) ?? .OPERATION_STATE_UNSPECIFIED
        quantity = realmOperation.quantity
        parentOperationId = realmOperation.parentOperationId
        figi = realmOperation.figi
        type = realmOperation.type
        price = realmOperation.price.map(Price.init)
        currency = Price.Currency(rawValue: realmOperation.currency) ?? .usd
        payment = realmOperation.payment.map(Price.init)
        quantityRest = realmOperation.quantityRest

        share = realmOperation.share.map(Share.init)
    }
}

extension OperationV2: Equatable {
    public static func == (lhs: OperationV2, rhs: OperationV2) -> Bool {
        lhs.id == rhs.id
    }
}

public extension OperationV2 {
    enum OperationState: String, Codable, Hashable {
        /// Статус операции не определён
        case OPERATION_STATE_UNSPECIFIED
        /// Исполнена
        case OPERATION_STATE_EXECUTED
        /// Отменена
        case OPERATION_STATE_CANCELED
    }

    enum OperationType: String, Codable, Hashable {
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
