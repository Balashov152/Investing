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
        .init(viewModel: .init())
    }

    static func homeView() -> HomeView {
        .init(viewModel: .init())
    }

    static func operationsView() -> OperationsView {
        .init(viewModel: .init())
    }

    static func analyticsView() -> AnalyticsView {
        .init(viewModel: .init())
    }

    // VIEWS

    static func comissionView() -> ComissionView {
        .init(viewModel: .init())
    }

    static func currencyView() -> CurrencyView {
        .init(viewModel: .init())
    }

    static func tickersView() -> TickersView {
        .init(viewModel: .init())
    }
}
