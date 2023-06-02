//
//  MainView.swift
//  Investing
//
//  Created by Sergey Balashov on 28.02.2022.
//

import Combine
import InvestModels
import InvestingUI
import InvestingFoundation
import SwiftUI

struct MainView: View {
    @ObservedObject private var viewModel: MainViewModel

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            ZStack {
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
                
                Color.clear
                    .sheet(item: $viewModel.accountsListViewModel) { viewModel in
                        AccountsListView(viewModel: viewModel)
                    }
                
                Color.clear
                    .sheet(item: $viewModel.instrumentDetailsViewModel) { viewModel in
                        InstrumentDetailsView(viewModel: viewModel)
                    }
            }
        }
    }

    var content: some View {
        GroupedScrollView {
            headerSection

            ForEach(viewModel.dataSource, id: \.id) { item in
                section(for: item)
            }
        }
        .background(Colors.Background.secondary)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    var headerSection: some View {
        GroupedSection(viewModel.headerViews) { item in
            switch item {
            case let .progress(text):
                Text(text)
                    .font(.callout)
                    .padding(.vertical)
                
            case let .error(text):
                Text("Error: \(text)")
                    .font(.callout)
                    .padding(.vertical)
                
            case let .total(moneyAmount):
                MoneyRow(label: "Итого в \(moneyAmount.currency.symbol)", money: moneyAmount)
                    .padding(.vertical)
            }
        }
    }
    
    func section(for item: PorfolioSectionViewModel) -> some View {
        GroupedSection(item) { item in
            RowDisclosureGroup {
                VStack(alignment: .leading, spacing: Constants.Paddings.s) {
                    Text(item.account.name).font(.title2).bold()
                    
                    ForEach(item.results, id: \.currency) { moneyAmount in
                        MoneyRow(label: "Итого в \(moneyAmount.currency.symbol)", money: moneyAmount)
                    }
                }
            } content: {
                LazyVStack {
                    ForEach(item.positions) { operation in
                        Divider()
                            .padding(.vertical, Constants.Paddings.xs)
                        
                        Button {
                            viewModel.openDetails(accountId: item.account.id, figi: operation.figi)
                        } label: {
                            PositionView(viewModel: operation)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.vertical)
        }
    }

    var sortView: some View {
        Menu {
            Picker(selection: $viewModel.sortType, label: EmptyView()) {
                ForEach(MainViewModel.SortType.allCases, id: \.self) {
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
            Button(action: { viewModel.openAccounts() } ) {
                Image(systemName: "list.number")
            }
            
            Button(action: { viewModel.refreshRates() } ) {
                Image(systemName: "dollarsign.arrow.circlepath")
            }
        }
    }
}
