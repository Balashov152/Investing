//
//  OperationsListView.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import Combine
import Foundation
import InvestModels
import SwiftUI

class OperationsListModel: ObservableObject {
    @Published var selectedFigi: String?
    @Published var figes: [String] = []
    @Published var operations: [OperationRowModel] = []

    private var account: BrokerAccount?
    private let portfolioManager: PortfolioManaging

    private var operationsCancellable: AnyCancellable?
    private var figesCancellable: AnyCancellable?

    init(portfolioManager: PortfolioManaging) {
        self.portfolioManager = portfolioManager
        account = portfolioManager.syncGetFirstSelectedAccount()
    }

    private func prepareOperations() {
        operationsCancellable = Publishers.CombineLatest(account.publisher, $selectedFigi)
            .receive(queue: .global())
            .map { account, selectedFigi -> [OperationRowModel] in
                if let selectedFigi = selectedFigi {
                    return account.operations
                        .filter { $0.figi == selectedFigi }
                        .map(OperationRowModel.init(operation:))

                } else {
                    return account.operations.map(OperationRowModel.init(operation:))
                }
            }
            .receive(queue: .main)
            .assign(to: \.operations, on: self)
    }

    private func prepareFiges() {
        figesCancellable = account.publisher
            .receive(queue: .global())
            .map { $0.operations.compactMap { $0.figi }.unique }
            .receive(queue: .main)
            .assign(to: \.figes, on: self)
    }
}

extension OperationsListModel: ViewLifeCycleOperator {
    func onAppear() {
        prepareOperations()
        prepareFiges()
    }
}

struct OperationsListView: View {
    @ObservedObject private var viewModel: OperationsListModel

    init(viewModel: OperationsListModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .center, spacing: Constants.Paddings.m) {
                        ForEach(viewModel.figes, id: \.self) { figi in
                            Button(action: {
                                viewModel.selectedFigi = figi
                            }, label: {
                                Text(figi)
                                    .foregroundColor(viewModel.selectedFigi == figi ? .purple : .black)
                            })
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 40)

                List(viewModel.operations) { operation in
                    OperationRow(viewModel: operation)
                }
            }
            .navigationBarTitle("OperationsListView")
            .navigationBarTitleDisplayMode(.inline)
        }
        .addLifeCycle(operator: viewModel)
    }
}
