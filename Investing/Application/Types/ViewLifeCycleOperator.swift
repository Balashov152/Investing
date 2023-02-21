//
//  ViewLifeCycleOperator.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2022.
//

import SwiftUI

public protocol ViewLifeCycleOperator {
    func onAppear()
    func onDisappear()
}

public extension ViewLifeCycleOperator {
    func onAppear() {}
    func onDisappear() {}
}

public extension View {
    func addLifeCycle(operator: ViewLifeCycleOperator) -> some View {
        self
            .onAppear(perform: `operator`.onAppear)
            .onDisappear(perform: `operator`.onDisappear)
    }
}
