//
//  ViewLifeCycleOperator.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2022.
//

import SwiftUI

extension View {
    func addLifeCycle(operator: ViewLifeCycleOperator) -> some View {
        onAppear(perform: `operator`.onAppear)
            .onDisappear(perform: `operator`.onDisappear)
    }
}

protocol ViewLifeCycleOperator {
    func onAppear()
    func onDisappear()
}

extension ViewLifeCycleOperator {
    func onAppear() {}
    func onDisappear() {}
}

public extension EnvironmentValues {
    var isOnAppearDidCall: Bool {
        get {
            return self[OnAppearDidCall.self]
        }
        set {
            self[OnAppearDidCall.self] = newValue
        }
    }
}

struct OnAppearDidCall: EnvironmentKey {
    static let defaultValue: Bool = false
}

public extension View {
    /**
     When enabled, button will be disabled but appearance won't change
     */
    @inlinable func onAppearCall(_ called: Bool = true) -> some View {
        environment(\.isOnAppearDidCall, called)
    }
}
