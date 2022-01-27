//
//  TabBarViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2022.
//

import Combine
import SwiftUI

class TabBarViewModel: CancebleObject, ObservableObject {
    @Published var isAuthorized: Bool = true
    @Published var isPresentAccounts: Bool = false

    @Published var loadingState: ContentState = .loading

    public let moduleFactory: ModuleFactoring
    private let realmStorage: RealmStoraging
    private let operationsManager: OperationsManaging
    private let instrumentsManager: InstrumentsManaging

    init(
        moduleFactory: ModuleFactoring,
        operationsManager: OperationsManaging,
        instrumentsManager: InstrumentsManaging,
        realmStorage: RealmStoraging
    ) {
        self.moduleFactory = moduleFactory
        self.operationsManager = operationsManager
        self.instrumentsManager = instrumentsManager
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

        updateOperations()
    }

    func checkIfAuthorized() {
        isAuthorized = Storage.isAuthorized
    }

    func updateOperations() {
        operationsManager.updateOperations()
            .tryMap { [unowned self] _ -> AnyPublisher<Void, Error> in
                instrumentsManager.updateInstruments()
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                print(completion.error)
                assert(completion.error == nil)
            }) { [unowned self] _ in
                self.loadingState = .content
            }
            .store(in: &cancellables)
    }
}
