//
//  DetailCurrencyView.swift
//  Investing
//
//  Created by Sergey Balashov on 15.01.2021.
//

import Combine
import InvestModels
import SwiftUI

class DetailCurrencyViewModel: EnvironmentCancebleObject, ObservableObject {
    let currency: Currency
    let operations: [Operation]

    var avg: MoneyAmount {
        return MoneyAmount(currency: currency,
                           value: operations.filter { $0.operationType == .Buy || $0.operationType == .Sell }
                               .reduce(0) { result, operation in
                                   (result + operation.price) / 2
                               })
    }

    var totalBuy: MoneyAmount {
        return MoneyAmount(currency: currency,
                           value: Double(operations.filter { $0.operationType == .Buy }
                               .reduce(0) { $0 + $1.quantityExecuted }))
    }

    var totalSellRUB: MoneyAmount {
        return MoneyAmount(currency: .RUB,
                           value: Double(operations.filter { $0.operationType == .Buy }
                               .reduce(0) { $0 + $1.payment }))
    }

    init(currency: Currency, operations: [Operation], env: Environment) {
        self.currency = currency
        self.operations = operations

        super.init(env: env)
    }
}

struct DetailCurrencyView: View {
    @ObservedObject var viewModel: DetailCurrencyViewModel

    var body: some View {
        List {
            HStack {
                Text("Avg")
                Spacer()
                CurrencyText(money: viewModel.avg)
            }

            HStack {
                Text("TotalBuy")
                Spacer()
                CurrencyText(money: viewModel.totalBuy)
            }

            HStack {
                Text("Total sell RUB")
                Spacer()
                CurrencyText(money: viewModel.totalSellRUB)
            }

        }.navigationTitle(viewModel.currency.rawValue)
    }
}
