//
//  AccountsListView.swift
//  Investing
//
//  Created by Sergey Balashov on 06.01.2023.
//

import SwiftUI

struct AccountsListView: View {
    @ObservedObject private var viewModel: AccountsListViewModel

    init(viewModel: AccountsListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            switch viewModel.state {
            case .loading:
                loadingView

            case .content:
                content

            case let .failure(error):
                Text(error.errorDescription ?? "")
                    .foregroundColor(.red)
            }
        }
        .addLifeCycle(operator: viewModel)
    }

    @ViewBuilder private var loadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())

            Text("Loading...".localized).font(.title)
            if let progress = viewModel.progress {
                Text(progress.title).font(.callout)
            }
        }
    }

    private var content: some View {
        ZStack {
            ScrollView {
                ForEach(viewModel.accounts, id: \.id) { account in
                    accountView(account: account)
                }
            }
            .navigationBarTitleDisplayMode(.inline)

            VStack {
                Spacer()

                ActionButton(title: "Сохранить") {
                    viewModel.savedSelectedAccounts()
                }
                .padding()
            }
        }
    }

    private func accountView(account: BrokerAccount) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(account.type.rawValue.lowercased())
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()

            Button(action: {
                if let index = viewModel.selectionAccounts.firstIndex(of: account) {
                    viewModel.selectionAccounts.remove(at: index)
                } else {
                    viewModel.selectionAccounts.append(account)
                }
            }, label: {
                let isSelected = viewModel.selectionAccounts.contains(account)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                    .resizable()
                    .foregroundColor(isSelected ? .purple : .gray)
                    .frame(width: 20, height: 20)
                    .cornerRadius(10)
            })
        }
        .padding()
    }
}
