//
//  ViewFactory.swift
//  SELLFASHION
//
//  Created by Sergey Balashov on 14.10.2020.
//  Copyright © 2020 Egor Otmakhov. All rights reserved.
//

import Foundation
import InvestModels

struct ViewFactory {
    // MAIN TABS
    static func mainView() -> MainView {
        .init(viewModel: .init())
    }

    static func homeView() -> HomeView {
        .init(viewModel: .init())
    }

    static func analyticsView() -> AnalyticsView {
        .init(viewModel: .init())
    }

    static func operationsView() -> OperationsView {
        .init(viewModel: .init())
    }

    static func settingsTabView() -> SettingsTabView {
        .init(viewModel: .init())
    }

    // VIEWS

    static func comissionView() -> ComissionView {
        .init(viewModel: .init())
    }

    // Currency
    static func currencyView() -> CurrencyView {
        .init(viewModel: .init())
    }

    static func detailCurrencyView(currency: Currency, operations: [Operation], env: Environment) -> DetailCurrencyView {
        .init(viewModel: .init(currency: currency, operations: operations, env: env))
    }

    static func tickersView() -> TickersView {
        .init(viewModel: .init())
    }

    static func dividentsView() -> DividentsView {
        .init(viewModel: .init())
    }
}
