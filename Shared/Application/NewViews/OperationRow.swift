//
//  OperationRow.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import Foundation
import InvestModels
import SwiftUI

struct OperationRowModel: Identifiable, Hashable {
    let id: String
    let date: Date
    let parentOperationId: String?
    let description: String
    let price: MoneyAmount
    let payment: MoneyAmount
    let quantity: String?
    let quantityRest: String?
    let operationType: String
    let state: String
    let ticker: String
    let figi: String
    let name: String

    init(operation: OperationV2) {
        id = operation.id ?? "ID"
        date = operation.date ?? .now
        parentOperationId = operation.parentOperationId
        description = operation.type ?? "operation.type"

        if let price = operation.price {
            self.price = MoneyAmount(currency: price.currency, value: price.price)
        } else {
            price = .zero
        }

        if let payment = operation.payment {
            self.payment = MoneyAmount(currency: payment.currency, value: payment.price)
        } else {
            payment = .zero
        }

        quantity = operation.quantity
        quantityRest = operation.quantityRest
        operationType = operation.operationType?.rawValue ?? "operationType"
        state = operation.state.rawValue
        ticker = operation.share?.ticker ?? "ticker"
        figi = operation.figi ?? "FIGI"
        name = operation.share?.name ?? operation.instrumentType?.rawValue ?? "NOT TYPE"
    }
}

struct OperationRow: View {
    private let viewModel: OperationRowModel

    init(viewModel: OperationRowModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Paddings.m) {
            VStack(alignment: .leading, spacing: Constants.Paddings.m) {
                Text(viewModel.id)
                Text(viewModel.date.string(format: "dd-MM-yyyy HH:mm:ss"))
                Text(viewModel.parentOperationId ?? "parentOperationId")
                Text(viewModel.description)
            }
            MoneyRow(label: "стоимость", money: viewModel.price)
            MoneyRow(label: "всего", money: viewModel.payment)
            VStack(alignment: .leading, spacing: Constants.Paddings.m) {
                Text(viewModel.quantity ?? "quantity")
                Text(viewModel.quantityRest ?? "quantityRest")
                Text(viewModel.operationType)
                Text(viewModel.state)
                Text(viewModel.ticker)
                Text(viewModel.figi)
                Text(viewModel.name)
            }
        }
        .padding()
    }
}
