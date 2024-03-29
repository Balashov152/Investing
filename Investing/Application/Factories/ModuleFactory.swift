//
//  ModuleFactory.swift
//  Investing (iOS)
//
//  Created by Sergey Balashov on 18.01.2022.
//

protocol ModuleFactoring {
    func tabBarModule() -> TabBarViewModel
    func loginView(output: LoginViewOutput) -> LoginViewModel

    func accountsList(output: AccountsListOutput) -> AccountsListViewModel
//    func investResults() -> InvestResultsViewModel
    func operationsList() -> OperationsListViewModel
    func mainView(output: MainViewOutput) -> MainViewModel
    func instrumentDetailsView(accountId: String, figi: String) -> InstrumentDetailsViewModel
}

struct ModuleFactory {
    let dependencyFactory: DependencyFactory
}

extension ModuleFactory: ModuleFactoring {
    func tabBarModule() -> TabBarViewModel {
        TabBarViewModel(
            moduleFactory: self,
            dataBaseManager: dependencyFactory.dataBaseManager,
            realmStorage: dependencyFactory.realmStorage
        )
    }
    
    func loginView(output: LoginViewOutput) -> LoginViewModel {
        LoginViewModel(
            portfolioManager: dependencyFactory.portfolioManager,
            output: output
        )
    }
    
    func accountsList(output: AccountsListOutput) -> AccountsListViewModel {
        AccountsListViewModel(
            output: output,
            portfolioManager: dependencyFactory.portfolioManager,
            realmStorage: dependencyFactory.realmStorage,
            dataBaseManager: dependencyFactory.dataBaseManager
        )
    }
    
//    func investResults() -> InvestResultsViewModel {
//        InvestResultsViewModel(realmStorage: dependencyFactory.realmStorage)
//    }
    
    func operationsList() -> OperationsListViewModel {
        OperationsListViewModel(
            portfolioManager: dependencyFactory.portfolioManager,
            realmStorage: dependencyFactory.realmStorage
        )
    }
    
    func mainView(output: MainViewOutput) -> MainViewModel {
        MainViewModel(
            output: output,
            realmStorage: dependencyFactory.realmStorage,
            calculatorManager: dependencyFactory.calculatorManager,
            moduleFactory: self
        )
    }
    
    func instrumentDetailsView(accountId: String, figi: String) -> InstrumentDetailsViewModel {
        InstrumentDetailsViewModel(
            realmStorage: dependencyFactory.realmStorage,
            accountId: accountId,
            figi: figi
        )
    }
}
