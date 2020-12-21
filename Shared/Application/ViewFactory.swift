//
//  ViewFactory.swift
//  SELLFASHION
//
//  Created by Sergey Balashov on 14.10.2020.
//  Copyright © 2020 Egor Otmakhov. All rights reserved.
//

import Foundation
import UIKit

struct ViewFactory {
    
    // MAIN TABS
    static func mainView() -> MainView {
        .init(viewModel: .init(accountService: .init(), positionService: .init(),
                               operationsService: .init(), instrumentsStorage: .init()))
    }
    
    static func homeView(mainViewModel: MainViewModel) -> HomeView {
        .init(viewModel: .init(mainViewModel: mainViewModel))
    }
    
    static func operationsView(mainViewModel: MainViewModel) -> OperationsView {
        .init(viewModel: .init(mainViewModel: mainViewModel))
    }
    
    // VIEWS
//    static func balanceView(mainViewModel: MainViewModel) -> BalanceView {
//        .init(viewModel: .init(mainViewModel: mainViewModel))
//    }
    
    static func comissionView(mainViewModel: MainViewModel) -> ComissionView {
        .init(viewModel: .init(mainViewModel: mainViewModel))
    }
    
    static func currencyView(mainViewModel: MainViewModel) -> CurrencyView {
        .init(viewModel: .init(mainViewModel: mainViewModel))
    }
    
    static func tickersView(mainViewModel: MainViewModel) -> TickersView {
        .init(viewModel: .init(mainViewModel: mainViewModel))
    }
}
