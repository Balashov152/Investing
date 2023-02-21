//
//  TabBarViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2022.
//

import Combine
import SwiftUI
import InvestingFoundation
import InvestingStorage

class TabBarViewModel: CancelableObject, ObservableObject {
    @Published var isAuthorized: Bool = true
    @Published var isPresentAccounts: Bool = false
    @Published var loadingState: ContentState = .content
    
    // MARK: - Child View models

    lazy var porfolioViewModel = moduleFactory.porfolioView(output: self)
    lazy var accountsListViewModel = moduleFactory.accountsList(output: self)
    lazy var loginViewModel = moduleFactory.loginView(output: self)
    lazy var operationsListModel = moduleFactory.operationsList()

    private let moduleFactory: ModuleFactoring
    private let dataBaseManager: DataBaseManaging
    private let realmStorage: RealmStoraging

    init(
        moduleFactory: ModuleFactoring,
        dataBaseManager: DataBaseManaging,
        realmStorage: RealmStoraging
    ) {
        self.moduleFactory = moduleFactory
        self.dataBaseManager = dataBaseManager
        self.realmStorage = realmStorage
    }
}

extension TabBarViewModel: ViewLifeCycleOperator {
    func onAppear() {
        startCheckings()
    }
}

extension TabBarViewModel: LoginViewOutput {
    func didSuccessLogin() {
        isAuthorized = true

        startCheckings()
    }
}

extension TabBarViewModel: AccountsListOutput {
    func accountsDidSelectAccounts() {
        isPresentAccounts = false

        startCheckings()
    }
}

private extension TabBarViewModel {
    func startCheckings() {
        checkIfAuthorized()

        guard isAuthorized else { return }

        isPresentAccounts = realmStorage.selectedAccounts().isEmpty

        guard !isPresentAccounts else { return }

//        updateOperations()
    }

    func checkIfAuthorized() {
        isAuthorized = !Storage.newToken.isEmpty
    }

    func updateOperations(completion: @escaping () -> Void = {}, progress: @escaping (DataBaseManager.UpdatingProgress) -> ()) {
        dataBaseManager.updateDataBase(progress: progress)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [unowned self] completion in
                if let error = completion.error {
                    loadingState = .failure(error: .simpleError(string: error.localizedDescription))
                }
            }) { [unowned self] _ in
                if self.loadingState != .content {
                    self.loadingState = .content
                }
                completion()
            }
            .store(in: &cancellables)
    }
    
    func updatePortfolio(completion: @escaping () -> Void = {}, progress: @escaping (DataBaseManager.UpdatingProgress) -> ()) {
        dataBaseManager.updatePortfolio(progress: progress)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [unowned self] completion in
                if let error = completion.error {
                    loadingState = .failure(error: .simpleError(string: error.localizedDescription))
                }
            }) { [unowned self] _ in
                if self.loadingState != .content {
                    self.loadingState = .content
                }
                completion()
            }
            .store(in: &cancellables)
    }
    

}

extension TabBarViewModel: PorfolioViewOutput {
    func didRequestRefresh(
        _ option: PorfolioRefreshOptions,
        completion: @escaping () -> Void,
        progress: @escaping (DataBaseManager.UpdatingProgress) -> ()
    ) {
        switch option {
        case .all:
            updateOperations(completion: completion, progress: progress)
        case .rates:
            updatePortfolio(completion: completion, progress: progress)
        }
    }
    
    func didRequestRefresh(completion: @escaping () -> Void, progress: @escaping (DataBaseManager.UpdatingProgress) -> ()) {
        
    }
}
