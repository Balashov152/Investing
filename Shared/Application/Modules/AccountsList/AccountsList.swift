//
//  AccountsList.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2022.
//

import SwiftUI

protocol AccountsListOutput: AnyObject {
    func accountsDidSelectAccounts()
}

class AccountsListViewModel: CancebleObject, ObservableObject {
    @Published var accounts: [BrokerAccount] = []
    @Published var selectionAccounts: [BrokerAccount] = []

    private weak var output: AccountsListOutput?
    private let portfolioManager: PortfolioManaging
    private let realmStorage: RealmStoraging

    init(
        output: AccountsListOutput,
        portfolioManager: PortfolioManaging,
        realmStorage: RealmStoraging
    ) {
        self.output = output
        self.portfolioManager = portfolioManager
        self.realmStorage = realmStorage
    }

    func savedSelectedAccounts() {
        realmStorage.saveSelectedAccounts(accounts: selectionAccounts)
        output?.accountsDidSelectAccounts()
    }
}

extension AccountsListViewModel: ViewLifeCycleOperator {
    func onAppear() {
        // TODO: ADD CONTENT STATE
        portfolioManager.userAccounts()
            .sink(receiveCompletion: { _ in
                // TODO: ADD ERROR HANDLE
            }, receiveValue: { [unowned self] accounts in
                self.accounts = accounts
            })
            .store(in: &cancellables)
    }
}

struct AccountsListView: View {
    @ObservedObject private var viewModel: AccountsListViewModel

    init(viewModel: AccountsListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    ForEach(viewModel.accounts, id: \.id) { account in
                        accountView(account: account)
                    }
                }
//                .toolbar {
//                    HStack {
//                        Spacer()
//
//                        Button(action: {
//                            viewModel.output?.accountsDidSelectAccounts()
//                        }, label: {
//                            Image(systemName: "xmark")
//                        })
//                    }
//                }
                .navigationBarTitleDisplayMode(.inline)

                VStack {
                    Spacer()

                    ActionButton(title: "Сохранить") {
                        viewModel.savedSelectedAccounts()
                    }
                    .padding()
                }
            }
        }
        .addLifeCycle(operator: viewModel)
    }

    private func accountView(account: BrokerAccount) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(account.type.rawValue)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()

            Button(action: {
                if let index = viewModel.selectionAccounts.firstIndex(of: account) {
                    viewModel.selectionAccounts.remove(at: index)
                } else {
                    viewModel.selectionAccounts.append(account)
                }
            }, label: {
                let isSelected = viewModel.selectionAccounts.contains(account)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                    .resizable()
                    .foregroundColor(isSelected ? .purple : .gray)
                    .frame(width: 20, height: 20)
//                    .background(isSelected ? .purple : .clear)
                    .cornerRadius(10)
            })
        }
        .padding()
    }
}