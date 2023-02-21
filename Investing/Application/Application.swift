//
//  InvestingApp.swift
//  Shared
//
//  Created by Sergey Balashov on 08.12.2020.
//

import SwiftUI
import InvestingServices

@main
struct Application: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var appCoordinator: AppCoordinator {
        AppCoordinator(
            modulesFactory: ModuleFactory(
                dependencyFactory: DependencyFactory(
                    services: InvestingServicesFactory()
                )
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: appCoordinator)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        print(">> your code here !!")
        return true
    }
}
