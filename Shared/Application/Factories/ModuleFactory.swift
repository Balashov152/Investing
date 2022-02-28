//
//  ModuleFactory.swift
//  Investing (iOS)
//
//  Created by Sergey Balashov on 18.01.2022.
//

protocol ModuleFactoring {
    func switchVersionView() -> SwitchVersionView

    func tabBarModule() -> TabBarView
    func oldVersionView() -> RootView

    func loginView(output: LoginViewOutput) -> LoginView

    func accountsList(output: AccountsListOutput) -> AccountsListView
    func investResults() -> InvestResultsView
    func operationsList() -> OperationsListView
    func porfolioView() -> PorfolioView
}

struct ModuleFactory {
    let dependencyFactory: DependencyFactory
}

extension ModuleFactory: ModuleFactoring {
    func switchVersionView() -> SwitchVersionView {
        let vm = SwitchVersionViewModel(moduleFactory: self)
        return SwitchVersionView(viewModel: vm)
    }

    func tabBarModule() -> TabBarView {
        TabBarView(
            viewModel: TabBarViewModel(
                moduleFactory: self,
                dataBaseManager: dependencyFactory.dataBaseManager,
                realmStorage: dependencyFactory.realmStorage
            )
        )
    }

    func oldVersionView() -> RootView {
        RootView()
    }

    func loginView(output: LoginViewOutput) -> LoginView {
        let viewModel = LoginViewModel(
            portfolioManager: dependencyFactory.portfolioManager,
            output: output
        )

        return LoginView(viewModel: viewModel)
    }

    func accountsList(output: AccountsListOutput) -> AccountsListView {
        AccountsListView(
            viewModel: AccountsListViewModel(output: output,
                                             portfolioManager: dependencyFactory.portfolioManager,
                                             realmStorage: dependencyFactory.realmStorage)
        )
    }

    func investResults() -> InvestResultsView {
        InvestResultsView(
            viewModel: InvestResultsViewModel(realmStorage: dependencyFactory.realmStorage)
        )
    }

    func operationsList() -> OperationsListView {
        OperationsListView(viewModel: OperationsListModel(portfolioManager: dependencyFactory.portfolioManager))
    }

    func porfolioView() -> PorfolioView {
        PorfolioView(
            viewModel: PorfolioViewModel(
                realmStorage: dependencyFactory.realmStorage,
                moduleFactory: self
            )
        )
    }
}
