//
//  OperationsListViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 21.02.2023.
//

import Combine
import InvestModels
import InvestingStorage

class OperationsListViewModel: ObservableObject {
    @Published var selectedFigi: String?
    @Published var figes: [String] = []
    @Published var operations: [OperationRowModel] = []

    private let portfolioManager: PortfolioManaging
    private let realmStorage: RealmStoraging

    private var operationsCancellable: AnyCancellable?
    private var figesCancellable: AnyCancellable?

    init(
        portfolioManager: PortfolioManaging,
        realmStorage: RealmStoraging
    ) {
        self.portfolioManager = portfolioManager
        self.realmStorage = realmStorage
    }

    private func prepareOperations() {
        operationsCancellable = Just(())
            .receive(queue: .global())
            .map { [unowned self] _ -> [OperationRowModel] in
                realmStorage.selectedAccounts()
                   .reduce([], { result, account -> [OperationRowModel] in
                       let operations = account.operations.map {
                           OperationRowModel(operation: $0, accountName: account.name)
                       }
                       
                       return result + operations
                   })
                   .sorted(by: { $0.date > $1.date })
            }
            .receive(queue: .main)
            .assign(to: \.operations, on: self)
        

//        operationsCancellable = Publishers.CombineLatest(account.publisher, $selectedFigi)
//            .receive(queue: .global())
//            .map { account, selectedFigi -> [OperationRowModel] in
//                if let selectedFigi = selectedFigi {
//                    return account.operations
//                        .filter { $0.figi == selectedFigi }
//                        .map(OperationRowModel.init(operation:))
//
//                } else {
//                    return account.operations.map(OperationRowModel.init(operation:))
//                }
//            }
//            .receive(queue: .main)
//            .assign(to: \.operations, on: self)
    }

//    private func prepareFiges() {
//        figesCancellable = account.publisher
//            .receive(queue: .global())
//            .map { $0.operations.compactMap { $0.figi }.unique }
//            .receive(queue: .main)
//            .assign(to: \.figes, on: self)
//    }
}

extension OperationsListViewModel: ViewLifeCycleOperator {
    func onAppear() {
        prepareOperations()
//        prepareFiges()
    }
}
