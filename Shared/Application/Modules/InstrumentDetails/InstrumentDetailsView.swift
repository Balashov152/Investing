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
    @Published var dataSource: [InstrumentDetailsBlockViewModel] = []
    @Published var share: Share?

    private let realmStorage: RealmStoraging
    private let figi: String

    let refresh = PassthroughSubject<Void, Never>()

    init(
        realmStorage: RealmStoraging,
        figi: String
    ) {
        self.realmStorage = realmStorage
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
            .map { [unowned self] _ -> [InstrumentDetailsBlockViewModel] in
                realmStorage.selectedAccounts().compactMap { map(account: $0) }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.dataSource, on: self)
            .store(in: &cancellables)
    }

    func map(account: BrokerAccount) -> InstrumentDetailsBlockViewModel? {
        let operations = account.operations.filter { $0.figi == figi }
        
        guard !operations.isEmpty else {
            return nil
        }

        return InstrumentDetailsBlockViewModel(
            accountName: account.name,
            operations: operations.map { OperationRowModel(operation: $0) }
        )
    }
}

struct InstrumentDetailsView: View {
    @ObservedObject private var viewModel: InstrumentDetailsViewModel
    @State private var expanded: Set<InstrumentDetailsBlockViewModel> = []

    init(viewModel: InstrumentDetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List(viewModel.dataSource) { item in
            RowDisclosureGroup(element: item, expanded: expanded, content: {
                ForEach(item.operations) { operation in
                    OperationRow(viewModel: operation)
                }
            }) {
                VStack(alignment: .leading, spacing: Constants.Paddings.s) {
                    Text(item.accountName)
                        .bold()
                        .font(.title2)
                }
                .padding(.horizontal, Constants.Paddings.m)
            }
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
