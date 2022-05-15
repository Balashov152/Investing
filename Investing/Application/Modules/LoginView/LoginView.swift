//
//  LoginView.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2022.
//

import Combine
import SwiftUI

struct LoginView: View {
    @ObservedObject private var viewModel: LoginViewModel

    @State private var isInstuctionOpen: Bool = false
    @State private var apiToken: String = ""

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Чтобы пользоваться приложением, необходимо ввести токен Тинькофф инвестиций. Его можно взять в настройках, в веб версии")
                        Button("Просмотреть инструкцию", action: {
                            isInstuctionOpen.toggle()
                        }).foregroundColor(.blue)
                    }

                    VStack(alignment: .leading) {
                        Text("Enter token".localized).lineLimit(1)

                        TextField("api token".localized, text: $apiToken)
                            .textFieldStyle(PlainTextFieldStyle())
//                            .introspectTextField(customize: { textField in
//                                textField.becomeFirstResponder()
//                            })

                        Divider()
                    }
                    .padding(.top, 50)
                    .padding(.bottom, 50)

                    ActionButton(title: "Check".localized,
                                 action: checkToken)
                }.padding()
            }
            .accentColor(.appBlack)
            .navigationTitle("Autorization".localized)
            .sheet(isPresented: $isInstuctionOpen) {
                ViewFactory.instructionView
            }
        }
    }

    private func checkToken() {
        let token = apiToken.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !token.isEmpty else {
            // TODO: Show Error
            return
        }

        viewModel.tryToLoadAccounts(token: token)
    }
}
