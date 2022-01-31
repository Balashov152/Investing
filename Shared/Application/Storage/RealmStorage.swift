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
    func save(portfolio: Portfolio, for accountId: String)

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
        guard let account = realmAccount(for: accountId) else {
            return
        }

        let realmOperations = operations.map(RealmOperation.realmOperation(from:))
        realmOperations.forEach { $0.share = realmShare(for: $0.figi) }

        manager.writeBlock {
            account.operations.removeAll()
            account.operations.append(objectsIn: realmOperations)
        }
    }

    func saveShares(shares: [Share]) {
        let realmShares = shares.map(RealmShare.realmShare(from:))

        manager.write(objects: realmShares, policy: .modified)
    }

    func save(portfolio: Portfolio, for accountId: String) {
        guard let account = realmAccount(for: accountId) else {
            return
        }

        manager.writeBlock {
            account.portfolio = RealmPortfolio.realmPortfolio(from: portfolio)
        }
    }
}

private extension RealmStorage {
    func realmAccount(for accountId: String) -> RealmBrokerAccount? {
        let predicate = NSPredicate(format: "id == %@", accountId)
        return manager
            .objects(RealmBrokerAccount.self, predicate: predicate)
            .first
    }

    func account(for accountId: String) -> BrokerAccount? {
        let predicate = NSPredicate(format: "id == %@", accountId)
        return manager
            .objects(RealmBrokerAccount.self, predicate: predicate, syncMap: BrokerAccount.init)
            .first
    }

    func realmShare(for figi: String?) -> RealmShare? {
        guard let figi = figi else {
            return nil
        }

        let predicate = NSPredicate(format: "figi == %@", figi)

        return manager
            .objects(RealmShare.self, predicate: predicate)
            .first
    }

    func share(for figi: String?) -> Share? {
        guard let figi = figi else {
            return nil
        }

        let predicate = NSPredicate(format: "figi == %@", figi)

        return manager
            .objects(RealmShare.self, predicate: predicate, syncMap: Share.init)
            .first
    }
}
