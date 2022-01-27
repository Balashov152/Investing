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
                operationsManager: dependencyFactory.operationsManager,
                instrumentsManager: dependencyFactory.instrumentsManager,
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
}
