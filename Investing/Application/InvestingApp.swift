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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private let modulesFactory: ModuleFactoring
    private let tabBarModule: TabBarViewModel

    init() {
        let dependencyFactory = DependencyFactory()

        modulesFactory = ModuleFactory(dependencyFactory: dependencyFactory)
        tabBarModule = modulesFactory.tabBarModule()
    }

    var body: some Scene {
        let session = UserSession()

        WindowGroup {
            TabBarView(viewModel: tabBarModule)
                .environmentObject(session)
                .onAppear(perform: onAppearApp)
        }
    }

    func onAppearApp() {
        UIScrollView.appearance().keyboardDismissMode = .onDrag
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        print(">> your code here !!")
        return true
    }
}
