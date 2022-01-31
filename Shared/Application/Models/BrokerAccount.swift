//
//  BrokerAccount.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2022.
//

import Foundation

struct BrokerAccount: Decodable, Equatable {
    let id: String
    let type: AccountType
    let name: String

    let operations: [OperationV2]
    let portfolio: Portfolio?
}

extension BrokerAccount {
    enum AccountType: String, Codable, Equatable {
        case UNSPECIFIED = "ACCOUNT_TYPE_UNSPECIFIED"
        case TINKOFF = "ACCOUNT_TYPE_TINKOFF"
        case IIS = "ACCOUNT_TYPE_TINKOFF_IIS"
        case INVEST_BOX = "ACCOUNT_TYPE_INVEST_BOX"
    }
}

extension BrokerAccount {
    init(realmAccount: RealmBrokerAccount) {
        let type = BrokerAccount.AccountType(rawValue: realmAccount.type)

        self.init(
            id: realmAccount.id,
            type: type ?? .TINKOFF,
            name: realmAccount.name,
            operations: realmAccount.operations.map(OperationV2.init),
            portfolio: realmAccount.portfolio.map(Portfolio.init)
        )
    }
}
