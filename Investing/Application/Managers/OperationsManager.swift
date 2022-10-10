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
        // Load portfolios for every account
        return realmStorage.selectedAccounts()
            .map { account in
                operationsService.loadOperations(for: account)
                    .receive(on: DispatchQueue.global())
                    .handleEvents(receiveOutput: { [weak self] operations in
                        self?.realmStorage.saveOperations(operations: operations, for: account.id)
                    })
            }
            .combineLatest
            .eraseToAnyPublisher()
            .mapToVoid()
    }
}

extension OperationsManager {
    enum Errors: Error {
        case notSelectedAccounts
    }
}
