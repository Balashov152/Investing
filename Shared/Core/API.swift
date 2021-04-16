//
//  API.swift
//  Investing
//
//  Created by Sergey Balashov on 12.02.2021.
//

import Foundation

struct API {
    static let current = API(currencyPairLatest: { .shared },
                             positionService: { .shared },
                             accountService: .init(provider: .init()),
                             operationsService: .init(provider: .init(), realmManager: .shared),
                             instrumentsService: .init(provider: .init()),
                             candlesService: .init(provider: .init()))

    var currencyPairLatest: () -> CurrencyPairServiceLatest
    var positionService: () -> PositionsService

    var accountService: AccountService
    var operationsService: OperationsService
    var instrumentsService: InstrumentsService
    var candlesService: CandlesService
}
