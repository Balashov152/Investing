//
//  PorfolioView.swift
//  Investing
//
//  Created by Sergey Balashov on 28.02.2022.
//

import Combine
import InvestModels
import SwiftUI

struct PorfolioView: View {
    @ObservedObject private var viewModel: PorfolioViewModel

    init(viewModel: PorfolioViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            List(viewModel.dataSource) { item in
                Section {
                    ForEach(item.operations) { operation in
                        PorfolioPositionView(viewModel: operation)
                    }
                } header: {
                    Text(item.accountName)
                        .padding(.horizontal, Constants.Paddings.m)
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Портфель")
            .addLifeCycle(operator: viewModel)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    accountsView
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    sortView
                }
            }
            .sheet(
                isPresented: $viewModel.isPresentAccounts,
                onDismiss: {}
            ) {
                viewModel.moduleFactory.accountsList(output: viewModel)
            }
        }
    }

    var sortView: some View {
        Button(viewModel.sortType.localize) {
            viewModel.sortType = PorfolioViewModel.SortType(rawValue: viewModel.sortType.rawValue + 1) ?? .inProfile
        }
    }

    var accountsView: some View {
        Button("Аккаунты") {
            viewModel.isPresentAccounts = true
        }
    }
}
