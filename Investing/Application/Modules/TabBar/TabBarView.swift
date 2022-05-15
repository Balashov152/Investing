//
//  TabBarView.swift
//  Investing (iOS)
//
//  Created by Sergey Balashov on 18.01.2022.
//

import Foundation
import SwiftUI

struct TabBarView: View {
    @ObservedObject private var viewModel: TabBarViewModel
    @State private var selectedIndex = 0

    init(viewModel: TabBarViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        if viewModel.isAuthorized {
            contentView
                .addLifeCycle(operator: viewModel)
                .sheet(
                    isPresented: $viewModel.isPresentAccounts,
                    onDismiss: {}
                ) {
                    viewModel.moduleFactory.accountsList(output: viewModel)
                }

        } else {
            viewModel.moduleFactory.loginView(output: viewModel)
        }
    }

    @ViewBuilder private var contentView: some View {
        switch viewModel.loadingState {
        case .loading:
            loadingView
        case .content:
            tabBarView
        case let .failure(error):
            Text("error \(error.localizedDescription)")
        }
    }

    @ViewBuilder private var loadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())

            Text("Loading...".localized)
        }
    }

    @ViewBuilder private var tabBarView: some View {
        TabView(selection: $selectedIndex) {
            profileView
//            analyticsView
//            targetsView
            operationsView
        }
        .accentColor(Color.appBlack)
    }

    @ViewBuilder private var profileView: some View {
        viewModel.moduleFactory.porfolioView().tabItem {
            VStack {
                Image(systemName: selectedIndex == 0 ? "dollarsign.circle.fill" : "dollarsign.circle")

                Text("Portfolio".localized)

            }.font(.system(size: 16, weight: selectedIndex == 0 ? .bold : .regular))

        }.tag(0)
    }

    @ViewBuilder private var analyticsView: some View {
        ViewFactory.analyticsView.tabItem {
            VStack {
                Image(systemName: selectedIndex == 1 ? "chart.bar.fill" : "chart.bar")
                Text("Analytics".localized)
                    .font(.system(size: 16, weight: selectedIndex == 1 ? .bold : .regular))
            }
        }.tag(1)
    }

    @ViewBuilder private var targetsView: some View {
        ViewFactory.targetsView.tabItem {
            VStack {
                Image(systemName: "target")
                Text("Targets".localized)
            }.font(.system(size: 16, weight: selectedIndex == 0 ? .bold : .regular))
        }.tag(2)
    }

    @ViewBuilder private var operationsView: some View {
        viewModel.moduleFactory.operationsList().tabItem {
            VStack {
                Image(systemName: "list.bullet.rectangle")
                    .resizable()

                Text("Operations")
            }
            .font(.system(size: 16, weight: selectedIndex == 3 ? .bold : .regular))
        }
//        .tag(3)
    }
}
