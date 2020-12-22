//
//  InvestingApp.swift
//  Shared
//
//  Created by Sergey Balashov on 08.12.2020.
//

import InvestModels
import SwiftUI

public typealias Operation = InvestModels.Operation

@main
struct InvestingApp: App {
    var body: some Scene {
        WindowGroup {
            ViewFactory.mainView()
        }
    }
}
