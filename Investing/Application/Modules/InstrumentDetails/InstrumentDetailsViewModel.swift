//
//  InstrumentDetailsViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 21.02.2023.
//

import Foundation
import InvestModels
import InvestingStorage
import Combine

final class InstrumentDetailsViewModel: CancelableObject, ObservableObject, Identifiable {
    @Published var operations: [OperationRowModel] = []
    @Published var share: Share?

    private let realmStorage: RealmStoraging
    private let accountId: String
    private let figi: String

    init(
        realmStorage: RealmStoraging,
        accountId: String,
        figi: String
    ) {
        self.realmStorage = realmStorage
        self.accountId = accountId
        self.figi = figi
        
        super.init()
        
        updateDataSource()
        share = realmStorage.share(figi: figi)
    }
}

extension InstrumentDetailsViewModel: ViewLifeCycleOperator {
    func onAppear() {}
}

private extension InstrumentDetailsViewModel {
    func updateDataSource() {
        Just(())
            .receive(queue: .global())
            .map { [unowned self] _ -> [OperationRowModel] in
                self.realmStorage.selectedAccounts()
                    .filter { $0.id == accountId }
                    .first
                    .map { map(account: $0) } ?? []
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] operations in
                self.operations = operations
            })
            .store(in: &cancellables)
    }

    func map(account: BrokerAccount) -> [OperationRowModel] {
        account.operations
            .filter { $0.figi == figi }
            .map { OperationRowModel(operation: $0) }
    }
}
