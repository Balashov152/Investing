//
//  Environment.swift
//  Investing
//
//  Created by Sergey Balashov on 22.12.2020.
//

import Foundation
import InvestModels

extension Environment {
    static let current = Environment(settings: .shared,
                                     api: { .current })
}

struct Environment {
    var settings: Settings
    var api: () -> API

    var currencyPairService: CurrencyPairService { api().currencyPairService }
    var accountService: AccountService { api().accountService }
    var positionService: PositionsService { api().positionService }
    var operationsService: OperationsService { api().operationsService }
}

struct API {
    static let current = API(currencyPairService: .init(),
                             accountService: .init(),
                             positionService: .shared,
                             operationsService: .init(realmManager: RealmManager()),
                             instrumentsService: .init())

    var currencyPairService: CurrencyPairService
    var accountService: AccountService
    var positionService: PositionsService
    var operationsService: OperationsService
    var instrumentsService: InstrumentsService
}

struct DateInterval: Hashable, Codable {
    static let lastYear = DateInterval(start: Calendar.current.date(byAdding: .year, value: -1, to: Date())!, end: Date())

    let start, end: Date
}
