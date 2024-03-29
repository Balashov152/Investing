//
//  OperationRow.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import Foundation
import InvestModels
import SwiftUI

extension OperationRowModel: Identifiable {
    var id: String { _id ?? "\(hashValue)" }
}

struct OperationRowModel: Hashable {
    let accountName: String?
    
    private let _id: String?

    let date: Date
    let parentOperationId: String?
    let description: String
    let price: MoneyAmount
    let payment: MoneyAmount
    let quantity: String?
    let quantityRest: String?
    let operationType: String
    let state: String
    let ticker: String?
    let figi: String?
    let name: String?
    
    var hasQuantity: Bool {
        quantity != "0"
    }

    init(operation: OperationV2, accountName: String? = nil) {
        self.accountName = accountName
        _id = operation.id
        date = operation.date
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
        ticker = operation.share?.ticker
        figi = operation.figi
        name = operation.share?.name
    }
}

struct OperationRow: View {
    private let viewModel: OperationRowModel

    init(viewModel: OperationRowModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading) {
            if let account = viewModel.accountName {
                Text(account)
                    .lineLimit(1)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, Constants.Paddings.s)
            }
            
            mainView
                .padding(Constants.Paddings.s)
                .background(Color.appWhite)
                .cornerRadius(Constants.Paddings.s)
            
            debugInfoView
        }
    }
    
    var mainView: some View {
        VStack(alignment: .leading, spacing: Constants.Paddings.xs) {
            if let name = viewModel.name, let ticker = viewModel.ticker {
                VStack(alignment: .leading) {
                    Text(name).font(.title2).fontWeight(.semibold)
                    
                    Text(ticker).font(.caption).foregroundColor(.gray)
                }
            }
            
            HStack(spacing: Constants.Paddings.xxs) {
                Text(viewModel.description)

                Spacer()
                
                MoneyText(money: viewModel.payment)
                    .font(.body)
                    .layoutPriority(1)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(viewModel.date.string(format: "HH:mm:ss"))
                        .font(.footnote)
                    
                    
                    Text(viewModel.date.string(format: "dd.MM.yy"))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                if viewModel.hasQuantity, let quantity = viewModel.quantity {
                    Spacer()
                    
                    HStack(spacing: Constants.Paddings.xxxs) {
                        Text(quantity)
                            
                        Text("·")
                        
                        MoneyText(money: viewModel.price)
                    }
                    .font(.body)
                }
            }
        }
    }
    
    var debugInfoView: some View {
        HStack {
            VStack(alignment: .leading){
                Text("id: " + viewModel.id.lowercased())
                if let figi = viewModel.figi, !figi.isEmpty {
                    Text("figi: " + figi)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("type: " + viewModel.operationType.lowercased())
                Text("state: " + viewModel.state.lowercased())
            }
        }
        .lineLimit(1)
        .foregroundColor(.gray)
        .padding(.horizontal, Constants.Paddings.s)
        .font(.caption2)
    }
}

struct OperationRow_Preview: PreviewProvider {
    static let model = OperationRowModel(
        operation: OperationV2(id: "72461o27451", date: Date(), instrumentType: InstrumentTypeV2.share, quantity: "1", parentOperationId: "18124418489", figi: "VSAD4324234F", type: "Списание комиссии", price: Price(price: RealmPrice()), currency: .usd, payment: Price(price: RealmPrice()), quantityRest: "0", operationType: .OPERATION_TYPE_ACCRUING_VARMARJIN, state: .OPERATION_STATE_CANCELED)
    )
    
    static var previews: some View {
        ZStack {
            Color(uiColor: .groupTableViewBackground)
            
            OperationRow(viewModel: model)
                .padding()
        }
    }
}
