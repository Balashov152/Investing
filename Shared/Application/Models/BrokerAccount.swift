//
//  BrokerAccount.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2022.
//

import Foundation

struct BrokerAccount: Equatable {
    let id: String
    let type: AccountType
    let name: String

    let operations: [OperationV2]
    let portfolio: Portfolio?

    init(id: String, type: BrokerAccount.AccountType, name: String, operations: [OperationV2], portfolio: Portfolio?) {
        self.id = id
        self.type = type
        self.name = name
        self.operations = operations
        self.portfolio = portfolio
    }
}

extension BrokerAccount: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case name
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(forKey: .id)
        type = try values.decode(forKey: .type)
        name = try values.decode(forKey: .name)

        operations = []
        portfolio = nil
    }
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
