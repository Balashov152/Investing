//
//  API.swift
//  Investing
//
//  Created by Sergey Balashov on 12.02.2021.
//

import Foundation

struct API {
    static let current = API(currencyPairService: .init(provider: .init(isSandbox: false)),
                             accountService: .init(provider: .init(isSandbox: false)),
                             positionService: .shared(isSandbox: false),
                             operationsService: .init(provider: .init(isSandbox: false), realmManager: .shared),
                             instrumentsService: .init(provider: .init(isSandbox: false)))

    static let sandbox = API(currencyPairService: .init(provider: .init(isSandbox: true)),
                             accountService: .init(provider: .init(isSandbox: true)),
                             positionService: .shared(isSandbox: true),
                             operationsService: .init(provider: .init(isSandbox: true), realmManager: .shared),
                             instrumentsService: .init(provider: .init(isSandbox: true)))

    var currencyPairService: CurrencyPairService
    var accountService: AccountService
    var positionService: PositionsService
    var operationsService: OperationsService
    var instrumentsService: InstrumentsService
}
