//
//  OperationsView.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Combine
import Foundation
import InvestModels
import Moya
import SwiftUI

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

struct OperationsView: View {
    @ObservedObject var viewModel: OperationsViewModel

    var operations: [Operation] {
        viewModel.operations.filter { $0.operationType == viewModel.selectedType }
    }

    var avalibleTypes: [Operation.OperationTypeWithCommission] {
        Operation.OperationTypeWithCommission.allCases.filter { type in
            viewModel.operations.contains(where: { $0.operationType == .some(type) })
        }
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: segmentView) {
                    ForEach(operations, id: \.self) {
                        OperationRowView(operation: $0)
                    }
                }
            }
            .navigationTitle("Operations")
            .onAppear(perform: viewModel.loadOperaions)
        }
    }

    var segmentView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(avalibleTypes, id: \.self) { type in
                    Button(action: {
                        viewModel.selectedType = type
                    }, label: {
                        Text(type.rawValue)
                            .foregroundColor(Color.accentColor)
                            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                            .background(viewModel.selectedType == .some(type) ? Color(UIColor.systemGray2) : Color.clear)
                            .cornerRadius(7)
                            .textCase(nil)
                    })
                }
            }
        }.frame(height: 40)
    }
}
