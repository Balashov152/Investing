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
    static func homeView(mainViewModel: MainViewModel) -> HomeView {
        .init(viewModel: .init(mainViewModel: mainViewModel))
    }
    
    static func operationsView(mainViewModel: MainViewModel) -> OperationsView {
        .init(viewModel: .init(mainViewModel: mainViewModel, instrumentsStorage: InstrumentsStorage()))
    }
    
    static func balanceView(operations: [Operation]) -> BalanceView {
        .init(viewModel: .init(operations: operations))
    }
}
