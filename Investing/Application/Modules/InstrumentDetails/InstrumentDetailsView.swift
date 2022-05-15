//
//  InstrumentDetailsView.swift
//  Investing
//
//  Created by Sergey Balashov on 04.04.2022.
//

import Combine
import SwiftUI

struct InstrumentDetailsBlockViewModel: Identifiable, Hashable {
    var id: String { accountName }

    let accountName: String
    let operations: [OperationRowModel]
}

final class InstrumentDetailsViewModel: CancebleObject, ObservableObject {
    @Published var operations: [OperationRowModel] = []
    @Published var share: Share?

    private let realmStorage: RealmStoraging
    private let accountId: String
    private let figi: String

    let refresh = PassthroughSubject<Void, Never>()

    init(
        realmStorage: RealmStoraging,
        accountId: String,
        figi: String
    ) {
        self.realmStorage = realmStorage
        self.accountId = accountId
        self.figi = figi
    }
}

extension InstrumentDetailsViewModel: ViewLifeCycleOperator {
    func onAppear() {
        setupSubscribtion()
        share = realmStorage.share(figi: figi)
    }
}

private extension InstrumentDetailsViewModel {
    func setupSubscribtion() {
        refresh
            .prepend(())
            .receive(queue: .global())
            .map { [unowned self] _ -> [OperationRowModel] in
                realmStorage.selectedAccounts()
                    .filter { $0.id == accountId }
                    .first
                    .map { map(account: $0) } ?? []
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.operations, on: self)
            .store(in: &cancellables)
    }

    func map(account: BrokerAccount) -> [OperationRowModel] {
        account.operations
            .filter { $0.figi == figi }
            .map { OperationRowModel(operation: $0) }
    }
}

struct InstrumentDetailsView: View {
    @ObservedObject private var viewModel: InstrumentDetailsViewModel
    @State private var expanded: Set<InstrumentDetailsBlockViewModel> = []

    init(viewModel: InstrumentDetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List(viewModel.operations) { operation in
            OperationRow(viewModel: operation)
        }
        .listStyle(PlainListStyle())
        .refreshable {
            viewModel.refresh.send()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.share?.name ?? "Детали по инструменту")
        .addLifeCycle(operator: viewModel)
    }
}
