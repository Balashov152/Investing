//
//  InvestingApp.swift
//  Shared
//
//  Created by Sergey Balashov on 08.12.2020.
//

import InvestModels
import SwiftUI
import UIKit
import InvestingServices

public typealias Operation = InvestModels.Operation

@main
struct InvestingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private let modulesFactory: ModuleFactoring
    private let tabBarModule: TabBarViewModel

    init() {
        let dependencyFactory = DependencyFactory(services: InvestingServicesFactory())

        modulesFactory = ModuleFactory(dependencyFactory: dependencyFactory)
        tabBarModule = modulesFactory.tabBarModule()
    }

    var body: some Scene {
        WindowGroup {
            TabBarView(viewModel: tabBarModule)
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
