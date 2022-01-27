//
//  OperationsManager.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2022.
//

import Combine
import Foundation
import Moya

protocol OperationsManaging {
    func updateOperations() -> AnyPublisher<Void, Error>
}

class OperationsManager {
    private let operationsService: OperationsServing
    private let realmStorage: RealmStoraging

    init(
        operationsService: OperationsServing,
        realmStorage: RealmStoraging
    ) {
        self.operationsService = operationsService
        self.realmStorage = realmStorage
    }
}

extension OperationsManager: OperationsManaging {
    func updateOperations() -> AnyPublisher<Void, Error> {
        guard let account = realmStorage.selectedAccounts().first else {
            print("NON SELECTED ACCOUNTS")
            return Fail(error: Errors.notSelectedAccounts).eraseToAnyPublisher()
        }

        return operationsService.loadOperations(for: account)
            .receive(on: DispatchQueue.global())
            .tryMap { [weak self] operations -> AnyPublisher<Void, Error> in
                Future { promise in
                    self?.realmStorage.saveOperations(operations: operations, for: account.id)

                    promise(.success(()))
                }
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}

extension OperationsManager {
    enum Errors: Error {
        case notSelectedAccounts
    }
}
