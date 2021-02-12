//
//  API.swift
//  Investing
//
//  Created by Sergey Balashov on 12.02.2021.
//

import Foundation

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
