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
                var operations = operations
                self?.dummyOperations(accountId: account.id, operations: &operations)
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

extension OperationsManager {
    func dummyOperations(accountId: String, operations: inout [OperationV2]) {
        // "2019252754" ИИС
        // "2009576139" Брокерский
        
        let isBuying = accountId == "2009576139"
        operations.append(contentsOf: dummyOperations(isBuying: isBuying))
    }
    
    func dummyOperations(isBuying: Bool) -> [OperationV2] {
        [
            OperationV2(id: "\(isBuying ? "In" : "Out") Apple",
                        date: .from(string: "15.05.2023", format: "dd.MM.yyyy")!,
                        instrumentType: .share,
                        quantity: "13",
                        parentOperationId: nil,
                        figi: "BBG000B9XRY4",
                        type: "\(isBuying ? "Зачисление" : "Списание") акций",
                        price: Price(nano: 70000000, currency: .usd, units: "172"),
                        currency: .usd,
                        payment: Price(nano: isBuying ? -910000000 : 910000000,
                                       currency: .usd,
                                       units: isBuying ? "-2236": "2236"),
                        quantityRest: "0",
                        operationType: isBuying ? .OPERATION_TYPE_BUY : .OPERATION_TYPE_SELL,
                        state: .OPERATION_STATE_EXECUTED),
            OperationV2(id: "\(isBuying ? "In" : "Out") Tesla",
                        date: .from(string: "15.05.2023", format: "dd.MM.yyyy")!,
                        instrumentType: .share,
                        quantity: "25",
                        parentOperationId: nil,
                        figi: "BBG000N9MNX3",
                        type: "\(isBuying ? "Зачисление" : "Списание") акций",
                        price: Price(nano: 350000000, currency: .usd, units: "166"),
                        currency: .usd,
                        payment: Price(nano: isBuying ? -750000000 : 750000000,
                                       currency: .usd,
                                       units: isBuying ? "-4158" : "4158"),
                        quantityRest: "0",
                        operationType: isBuying ? .OPERATION_TYPE_BUY : .OPERATION_TYPE_SELL,
                        state: .OPERATION_STATE_EXECUTED),
            OperationV2(id: "\(isBuying ? "In" : "Out") Black Rock",
                        date: .from(string: "15.05.2023", format: "dd.MM.yyyy")!,
                        instrumentType: .share,
                        quantity: "2",
                        parentOperationId: nil,
                        figi: "BBG000C2PW58",
                        type: "\(isBuying ? "Зачисление" : "Списание") акций",
                        price: Price(nano: 750000000, currency: .usd, units: "644"), // 644.75
                        currency: .usd,
                        payment: Price(nano: isBuying ? -500000000 : 500000000,
                                       currency: .usd,
                                       units: isBuying ? "-1289" : "1289"), // 1289,5
                        quantityRest: "0",
                        operationType: isBuying ? .OPERATION_TYPE_BUY : .OPERATION_TYPE_SELL,
                        state: .OPERATION_STATE_EXECUTED),
            OperationV2(id: "\(isBuying ? "In" : "Out") Bank of America",
                        date: .from(string: "15.05.2023", format: "dd.MM.yyyy")!,
                        instrumentType: .share,
                        quantity: "15",
                        parentOperationId: nil,
                        figi: "BBG000BCTLF6",
                        type: "\(isBuying ? "Зачисление" : "Списание") акций",
                        price: Price(nano: 65, currency: .usd, units: "27"), // 27.65
                        currency: .usd,
                        payment: Price(nano: isBuying ? -750000000 : 750000000,
                                       currency: .usd,
                                       units: isBuying ? "-414" : "414"), // 414,75
                        quantityRest: "0",
                        operationType: isBuying ? .OPERATION_TYPE_BUY : .OPERATION_TYPE_SELL,
                        state: .OPERATION_STATE_EXECUTED)
        ]
    }
}
