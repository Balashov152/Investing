//
//  PositionDetailView.swift
//  InvestModels
//
//  Created by Sergey Balashov on 22.01.2021.
//

import Combine
import InvestModels
import SwiftUI

class PositionDetailViewModel: EnvironmentCancebleObject, ObservableObject {
    let position: PositionView

    @Published var operations: [Operation] = []

    var total: MoneyAmount {
        let value = position.totalInProfile.value + operations.currencySum(to: position.currency).value
        return MoneyAmount(currency: position.currency, value: value)
    }
    
//    var average: MoneyAmount {
//        
//    }

    init(position: PositionView, env: Environment) {
        self.position = position

        super.init(env: env)
    }

    override func bindings() {
        super.bindings()
        env.api().operationsService.$operations
            .receive(on: DispatchQueue.global())
            .map { [unowned self] operations in
                operations.filter { $0.instrument?.ticker == position.ticker }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.operations, on: self)
            .store(in: &cancellables)
    }

    public func load() {
        env.api().operationsService.getOperations(request: .init(env: env))
    }
}

struct PositionDetailView: View {
    @ObservedObject var viewModel: PositionDetailViewModel

    var body: some View {
        List {
            Section {
                MoneyRow(label: "Total all time", money: viewModel.total)
            }
            Section {
                DisclosureGroup(content: {
                    ForEach(viewModel.operations, id: \.self) {
                        OperationRowView(operation: $0)
                    }
                }, label: {
                    Text("All operations \(viewModel.operations.count)")

                })
            }
        }
        .onAppear(perform: viewModel.load)
        .listStyle(GroupedListStyle())
        .navigationTitle(viewModel.position.name.orEmpty)
    }
}
