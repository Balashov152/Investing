//
//  InvestingApp.swift
//  Shared
//
//  Created by Sergey Balashov on 08.12.2020.
//

import SwiftUI

@main
struct InvestingApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(viewModel: .init())
        }
    }
}
