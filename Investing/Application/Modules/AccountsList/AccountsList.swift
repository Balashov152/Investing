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

    @Published var state: ContentState = .loading

    private weak var output: AccountsListOutput?
    private let portfolioManager: PortfolioManaging
    private let realmStorage: RealmStoraging
    private let dataBaseManager: DataBaseManaging

    init(
        output: AccountsListOutput,
        portfolioManager: PortfolioManaging,
        realmStorage: RealmStoraging,
        dataBaseManager: DataBaseManaging
    ) {
        self.output = output
        self.portfolioManager = portfolioManager
        self.realmStorage = realmStorage
        self.dataBaseManager = dataBaseManager
    }

    func savedSelectedAccounts() {
        realmStorage.saveSelectedAccounts(accounts: selectionAccounts)

        state = .loading

        dataBaseManager.updateDataBase()
            .sink(receiveCompletion: { completion in
                print("updateDataBase ERROR", completion.error)
            }, receiveValue: { [unowned self] in
                output?.accountsDidSelectAccounts()
            })
            .store(in: &cancellables)
    }
}

extension AccountsListViewModel: ViewLifeCycleOperator {
    func onAppear() {
        state = .loading

        portfolioManager.userAccounts()
            .sink(receiveCompletion: { completion in
                assert(completion.error == nil)
            }, receiveValue: { [unowned self] accounts in
                self.accounts = accounts
                self.selectionAccounts = self.realmStorage.selectedAccounts()

                self.state = .content
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
            switch viewModel.state {
            case .loading:
                loadingView

            case .content:
                content

            case let .failure(error):
                Text(error.errorDescription ?? "")
                    .foregroundColor(.red)
            }
        }
        .addLifeCycle(operator: viewModel)
    }

    @ViewBuilder private var loadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())

            Text("Loading...".localized)
        }
    }

    private var content: some View {
        ZStack {
            ScrollView {
                ForEach(viewModel.accounts, id: \.id) { account in
                    accountView(account: account)
                }
            }
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

    private func accountView(account: BrokerAccount) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(account.type.rawValue.lowercased())
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
                    .cornerRadius(10)
            })
        }
        .padding()
    }
}
