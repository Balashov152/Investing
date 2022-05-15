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

extension UIDevice {
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
            // We're on the simulator
            return true
        #else
            // We're on a device
            return false
        #endif
    }
}

@main
struct InvestingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private let modulesFactory: ModuleFactoring

    init() {
        let dependencyFactory = DependencyFactory()

        modulesFactory = ModuleFactory(dependencyFactory: dependencyFactory)
    }

    var body: some Scene {
        let session = UserSession()

        WindowGroup {
            modulesFactory
                .switchVersionView()
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
