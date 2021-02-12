//
//  Environment.swift
//  Investing
//
//  Created by Sergey Balashov on 22.12.2020.
//

import Foundation
import InvestModels

extension Environment {
    static let current = Environment(settings: .shared, api: { .current })
}

struct Environment {
    var settings: Settings
    var api: () -> API

    var currencyPairService: CurrencyPairService { api().currencyPairService }
    var accountService: AccountService { api().accountService }
    var positionService: PositionsService { api().positionService }
    var operationsService: OperationsService { api().operationsService }
}
