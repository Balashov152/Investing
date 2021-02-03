//
//  InvestingApp.swift
//  Shared
//
//  Created by Sergey Balashov on 08.12.2020.
//

import InvestModels
import SwiftUI
import UIKit

public typealias Operation = InvestModels.Operation

@main
struct InvestingApp: App {
    var body: some Scene {
        let session = UserSession()

        WindowGroup {
            RootView()
                .environmentObject(session)
                .onAppear(perform: onAppearApp)
        }
    }

    func onAppearApp() {
        UIScrollView.appearance().keyboardDismissMode = .onDrag
    }
}
