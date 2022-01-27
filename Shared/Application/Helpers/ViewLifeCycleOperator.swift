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
