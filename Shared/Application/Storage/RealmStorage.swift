//
//  RealmManager.swift
//  Investing (iOS)
//
//  Created by Sergey Balashov on 25.01.2022.
//

import Foundation
import RealmSwift

protocol RealmStoraging {
    func brokerAccounts() -> [BrokerAccount]
    func saveAccounts(accounts: [BrokerAccount])

    func saveSelectedAccounts(accounts: [BrokerAccount])
    func selectedAccounts() -> [BrokerAccount]

    func saveOperations(operations: [OperationV2], for accountId: String)
    func operations(for accountId: String) -> [OperationV2]

    func saveShares(shares: [Share])
}

class RealmStorage {
    let manager = RealmManager.shared
}

extension RealmStorage: RealmStoraging {
    func saveAccounts(accounts: [BrokerAccount]) {
        let accounts = accounts.map { account -> RealmBrokerAccount in
            let realmBrokerAccount = RealmBrokerAccount()
            realmBrokerAccount.id = account.id
            realmBrokerAccount.type = account.type.rawValue
            realmBrokerAccount.name = account.name

            return realmBrokerAccount
        }

        manager.write(objects: accounts)
    }

    func saveSelectedAccounts(accounts: [BrokerAccount]) {
        let savedAccounts = manager.objects(RealmBrokerAccount.self)

        savedAccounts.forEach { savedAccount in
            manager.writeBlock {
                savedAccount.isSelected = accounts.contains(where: { $0.id == savedAccount.id })
            }
        }
    }

    func brokerAccounts() -> [BrokerAccount] {
        manager.objects(RealmBrokerAccount.self).map(BrokerAccount.init)
    }

    func selectedAccounts() -> [BrokerAccount] {
        let predicate = NSPredicate(format: "isSelected == true")
        return manager
            .objects(RealmBrokerAccount.self, predicate: predicate, syncMap: BrokerAccount.init)
    }

    func saveOperations(operations: [OperationV2], for accountId: String) {
        let predicate = NSPredicate(format: "id == %@", accountId)

        guard let account = manager
            .objects(RealmBrokerAccount.self, predicate: predicate)
            .first
        else {
            return
        }

        let realmOperations = operations.map(RealmOperation.realmOperation(from:))
        manager.writeBlock {
            account.operations.removeAll()
            account.operations.append(objectsIn: realmOperations)
        }
    }

    func operations(for accountId: String) -> [OperationV2] {
        guard let account = manager
            .objects(RealmBrokerAccount.self)
            .first(where: { $0.id == accountId })
        else {
            return []
        }

        return account.operations.map(OperationV2.init)
    }

    func saveShares(shares: [Share]) {
        let realmShares = shares.map(RealmShare.realmShare(from:))

        manager.write(objects: realmShares, policy: .modified)
    }
}
