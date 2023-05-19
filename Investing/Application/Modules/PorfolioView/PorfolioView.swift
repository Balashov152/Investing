//
//  PorfolioView.swift
//  Investing
//
//  Created by Sergey Balashov on 28.02.2022.
//

import Combine
import InvestModels
import InvestingUI
import SwiftUI

struct PorfolioView: View {
    @ObservedObject private var viewModel: PorfolioViewModel

    init(viewModel: PorfolioViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            content
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
    
    @ViewBuilder var content: some View {
        switch viewModel.contentState {
        case .loading:
            VStack(spacing: 8) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                
                Text("Loading...".localized)
            }
        case .content:
            list
        case let .failure(error):
            VStack {
                Text("Error")
                    .font(.headline)
                
                Text(error.errorDescription ?? "")
            }
        }
    }
    
    
    var list: some View {
        GroupedScrollView {
            if let progress = viewModel.progress {
                Text(progress.title).font(.callout)
            }
            
            if let error = viewModel.error {
                Text("Error: \(error)").font(.callout)
            }
            
            VStack(alignment: .leading, spacing: Constants.Paddings.s) {
                ForEach(viewModel.totals, id: \.currency) { moneyAmount in
                    MoneyRow(label: "Итого в \(moneyAmount.currency.symbol)", money: moneyAmount)
                }
            }
            
            Divider()
                .padding(.vertical, Constants.Paddings.xs)
            
            ForEach(viewModel.dataSource) { item in
                RowDisclosureGroup {
                    VStack(alignment: .leading, spacing: Constants.Paddings.s) {
                        Text(item.account.name).font(.title2).bold()
                        
                        ForEach(item.results, id: \.currency) { moneyAmount in
                            MoneyRow(label: "Итого в \(moneyAmount.currency.symbol)", money: moneyAmount)
                        }
                    }
                } content: {
                    ForEach(item.positions) { operation in
                        PorfolioPositionView(viewModel: operation)
                            .addNavigationLink {
                                instrumentDetailsView(accountId: item.account.id,
                                                      figi: operation.figi)
                            }

                        Divider()
                            .padding(.vertical, Constants.Paddings.xs)
                    }
                }
                
                Divider()
                    .padding(.vertical, Constants.Paddings.xs)
            }
        }
        .animation(.default, value: viewModel.progress == nil)
        .listStyle(PlainListStyle())
        .refreshable {
            await viewModel.refresh()
        }
        
    }

    var sortView: some View {
        Menu {
            Picker(selection: $viewModel.sortType, label: EmptyView()) {
                ForEach(PorfolioViewModel.SortType.allCases, id: \.self) {
                    Text($0.localize)
                        .tag($0)
                }
            }
        } label: {
            Text(viewModel.sortType.localize)
                .font(.body)
        }
    }

    var accountsView: some View {
        HStack {
            Button(action: { viewModel.isPresentAccounts = true } ) {
                Image(systemName: "list.number")
            }
            
            Button(action: { viewModel.refreshRates() } ) {
                Image(systemName: "dollarsign.arrow.circlepath")
            }
        }
    }
    
    func instrumentDetailsView(accountId: String, figi: String) -> some View {
        InstrumentDetailsView(
            viewModel: viewModel.instrumentDetailsViewModel(accountId: accountId, figi: figi)
        )
    }
}
