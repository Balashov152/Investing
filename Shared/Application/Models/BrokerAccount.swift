//
//  BrokerAccount.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2022.
//

import Foundation

struct BrokerAccount: Codable, Equatable {
    let id: String
    let type: AccountType
    let name: String
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
            name: realmAccount.name
        )
    }
}
