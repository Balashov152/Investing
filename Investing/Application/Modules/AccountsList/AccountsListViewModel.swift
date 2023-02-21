//
//  AccountsListViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2022.
//

import SwiftUI
import InvestingFoundation
import InvestModels
import InvestingStorage

protocol AccountsListOutput: AnyObject {
    func accountsDidSelectAccounts()
}

class AccountsListViewModel: CancelableObject, ObservableObject {
    @Published var accounts: [BrokerAccount] = []
    @Published var selectionAccounts: [BrokerAccount] = []

    @Published var state: ContentState = .loading
    @Published var progress: DataBaseManager.UpdatingProgress?

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

        dataBaseManager.updateDataBase { [unowned self] progress in
            DispatchQueue.main.async { self.progress = progress }
        }
            .sink(receiveCompletion: { [unowned self] completion in
                if let error = completion.error {
                    state = .failure(error: .simpleError(string: error.localizedDescription))
                }
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
