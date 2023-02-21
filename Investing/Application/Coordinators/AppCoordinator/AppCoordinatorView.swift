//
//  AppCoordinatorView.swift
//  Investing
//
//  Created by Sergey Balashov on 21.02.2023.
//

import SwiftUI

struct AppCoordinatorView: View {
    @ObservedObject var coordinator: AppCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            rootView
        }
    }
    
    @ViewBuilder
    var rootView: some View {
        if let viewModel = coordinator.tabBarViewModel {
            TabBarView(viewModel: viewModel)
        }
    }
}
