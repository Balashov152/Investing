//
//  Environment.swift
//  Investing
//
//  Created by Sergey Balashov on 22.12.2020.
//

import Foundation

extension Environment {
    static let current = Environment(settings: { Settings() },
                                     dateInterval: { .lastYear },
                                     api: { .current },
                                     realmManager: { .shared })
}

struct Environment {
    var settings: () -> Settings
    var dateInterval: () -> DateInterval

    var api: () -> API

    var currencyPairService: CurrencyPairService { api().currencyPairService }
    var accountService: AccountService { api().accountService }
    var positionService: PositionsService { api().positionService }
    var operationsService: OperationsService { api().operationsService }

    var realmManager: () -> RealmManager
}

struct API {
    static let current = API(currencyPairService: .init(),
                             accountService: .init(),
                             positionService: .init(),
                             operationsService: .init())

    var currencyPairService: CurrencyPairService
    var accountService: AccountService
    var positionService: PositionsService
    var operationsService: OperationsService
}

struct DateInterval {
    static let lastYear = DateInterval(start: Calendar.current.date(byAdding: .year, value: -1, to: Date())!, end: Date())

    let start, end: Date
}
