//
//  OperationsViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 12.02.2021.
//

import Combine
import InvestModels

class OperationsViewModel: EnvironmentCancebleObject, ObservableObject {
    @Published var selectedType = Operation.OperationTypeWithCommission.Buy

    var operations: [Operation] {
        env.api().operationsService.operations
    }

    public func loadOperaions() {
        env.operationsService.getOperations(request: .init(env: env))
    }

    override func bindings() {
        super.bindings()
        env.operationsService.$operations.sink(receiveValue: { _ in
            self.objectWillChange.send()
        }).store(in: &cancellables)
    }
}
