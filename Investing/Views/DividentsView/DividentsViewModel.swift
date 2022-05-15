//
//  DividentsViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Combine
import InvestModels
import SwiftUI

class DividentsViewModel: EnvironmentCancebleObject, ObservableObject {
    @Published var dividents: [Operation] = []

    var instruments: [Instrument] {
        dividents
            .compactMap { $0.instrument }.unique
            .sorted(by: { $0.name < $1.name })
    }

    public func loadOperaions() {
        env.operationsService
            .getOperations(request: .init(env: env))
    }

    override func bindings() {
        super.bindings()
        env.operationsService.$operations
            .receive(on: DispatchQueue.global())
            .map { $0.filter(types: [.Dividend, .TaxDividend]) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.dividents, on: self)
            .store(in: &cancellables)
    }
}
