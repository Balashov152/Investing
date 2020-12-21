//
//  InvestingApp.swift
//  Shared
//
//  Created by Sergey Balashov on 08.12.2020.
//

import SwiftUI
import InvestModels

public typealias Operation = InvestModels.Operation

@main
struct InvestingApp: App {
    var body: some Scene {
        WindowGroup {
            ViewFactory.mainView()
        }
    }
}
