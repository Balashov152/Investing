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
    @State private var expanded: Set<PorfolioSectionViewModel> = []

    init(viewModel: PorfolioViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            Group {
                switch viewModel.contentState {
                case .loading:
                    VStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        
                        Text("Loading...".localized)
                    }
                case .content:
                    content
                case let .failure(error):
                    VStack {
                        Text("Error")
                            .font(.headline)
                        
                        Text(error.errorDescription ?? "")
                    }
                }
            }
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
                AccountsListView(viewModel: viewModel.accountsListViewModel)
            }
        }
    }
    
    var content: some View {
        List {
            if let progress = viewModel.progress {
                Text(progress.title).font(.callout)
            }
            
            VStack(alignment: .leading, spacing: Constants.Paddings.s) {
                ForEach(viewModel.totals, id: \.currency) { moneyAmount in
                    MoneyRow(label: "Итого в \(moneyAmount.currency.symbol)", money: moneyAmount)
                }
            }
            
            ForEach(viewModel.dataSource) { item in
                RowDisclosureGroup(element: item, expanded: expanded, content: {
                    ForEach(item.positions) { operation in
                        PorfolioPositionView(viewModel: operation)
                            .addNavigationLink {
                                instrumentDetailsView(accountId: item.account.id,
                                                      figi: operation.figi)
                            }
                    }
                }) {
                    VStack(alignment: .leading, spacing: Constants.Paddings.s) {
                        Text(item.account.name)
                            .bold()
                            .font(.title2)
                        
                        ForEach(item.results, id: \.currency) { moneyAmount in
                            MoneyRow(label: "Итого в \(moneyAmount.currency.symbol)", money: moneyAmount)
                        }
                    }
                }
            }
        }
        .animation(.easeInOut, value: viewModel.progress == nil)
        .listStyle(PlainListStyle())
        .refreshable {
            await viewModel.refresh()
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
    
    func instrumentDetailsView(accountId: String, figi: String) -> some View {
        InstrumentDetailsView(
            viewModel: viewModel.instrumentDetailsViewModel(accountId: accountId, figi: figi)
        )
    }
}
