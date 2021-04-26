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
    // MARK: Authorization

    static let instructionView: AuthorizationInstruction = {
        .init()
    }()

    // MARK: Main

    static let mainView: MainView = {
        .init(viewModel: .init())
    }()

    static let SettingsView: SettingsView = {
        .init(viewModel: .init())
    }()

    // MARK: Home views

    static let homeView: HomeView = {
        .init(viewModel: .init())
    }()

    static let ratesView: RatesView = {
        .init(viewModel: .init())
    }()

    static let totalDetailView: TotalDetailView = {
        .init(viewModel: .init())
    }()

    static func positionDetailView(position: PositionView, env: Environment) -> PositionDetailView {
        .init(viewModel: .init(position: position, env: env))
    }

    // MARK: Analytics

    static let analyticsView: AnalyticsView = {
        .init(viewModel: .init())
    }()

    static let payInView: PayInView = {
        .init(viewModel: .init())
    }()

    // VIEWS

    static let comissionView: ComissionView = {
        .init(viewModel: .init())
    }()

    // Currency
    static let currencyView: CurrencyView = {
        .init(viewModel: .init())
    }()

    static func detailCurrencyView(currency: Currency, operations: [Operation], env: Environment) -> DetailCurrencyView {
        .init(viewModel: .init(currency: currency, operations: operations, env: env))
    }

    static let tickersView: TickersView = {
        .init(viewModel: .init())
    }()

    static let dividentsView: DividentsView = {
        .init(viewModel: .init())
    }()

    // MARK: Need will be

    static let operationsView: OperationsView = {
        .init(viewModel: .init())
    }()

    static let targetsView: TargetsView = {
        .init(viewModel: .init())
    }()
}
