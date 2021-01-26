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
    @State var isAuthorized = Storage.isAuthorized

    var body: some Scene {
        WindowGroup {
            Group {
                if isAuthorized {
                    ViewFactory.mainView
                } else {
                    ViewFactory.authorizationView
                }
            }.onAppear(perform: onAppearApp)
        }
    }

    func onAppearApp() {
        UIScrollView.appearance().keyboardDismissMode = .onDrag
    }
}
