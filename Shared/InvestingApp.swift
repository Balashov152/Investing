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
public var isMe: Bool {
    UIDevice.isSimulator ||
        UIDevice.current.identifierForVendor?.uuidString == "E0531109-4C21-43CA-ACF4-ECD1C4AB3818"
}

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
