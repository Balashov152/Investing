//
//  OperationsManager.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2022.
//

import Combine
import Foundation
import Moya
import InvestModels
import InvestingServices
import InvestingStorage

protocol OperationsManaging {
    func updateOperations(progress: @escaping (OperationsManager.UpdatingProgress) -> ()) -> AnyPublisher<Void, Error>
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
    func updateOperations(progress: @escaping (UpdatingProgress) -> ()) -> AnyPublisher<Void, Error> {
        /// Load portfolios for every account
        let publishers = realmStorage.selectedAccounts().map { account in
            operationsService.loadOperations(for: account) {
                progress(UpdatingProgress(account: account, progress: $0))
            }
            .receive(on: DispatchQueue.global())
            .handleEvents(receiveOutput: { [weak self] operations in
                self?.realmStorage.saveOperations(operations: operations, for: account.id)
            })
        }
        
        return Publishers.Sequence(sequence: publishers)
            .flatMap(maxPublishers: .max(1)) { $0 }
            .collect(publishers.count)
            .mapVoid()
            .eraseToAnyPublisher()
    }
}

extension OperationsManager {
    enum Errors: Error {
        case notSelectedAccounts
    }
    
    struct UpdatingProgress {
        public init(account: BrokerAccount, progress: LoadingProgress) {
            self.account = account
            self.progress = progress
        }
        
        public let account: BrokerAccount
        public let progress: LoadingProgress
    }
}
