//
//  AuthorizationView.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2021.
//

import Combine
import Foundation
import Introspect
import Moya
import SwiftUI
import UIKit

class AuthorizationViewModel: EnvironmentCancebleObject, ObservableObject {
    let session: UserSession

    @Published var isSandbox: Bool {
        willSet {
            env.settings.isSandbox = newValue
        }
    }

    @Published var error: String?
    @Published var apiToken: String = "" {
        willSet {
            error = nil
        }
    }

    lazy var actionButton: () -> Void = { [unowned self] in
        Storage.token = self.apiToken

        self.env.api().accountService.getAccounts()
            .sink { error in
                switch error {
                case let .failure(error):
                    Storage.token = ""
                    self.error = "Token is invalid".localized
                case .finished:
                    break
                }
            } receiveValue: { _ in
                self.session.isAuthorized = true
            }.store(in: &self.cancellables)
    }

    init(session: UserSession, env: Environment = .current) {
        self.session = session
        isSandbox = env.settings.isSandbox

        super.init(env: env)
    }
}

struct AuthorizationView: View {
    @ObservedObject var viewModel: AuthorizationViewModel

    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Чтобы пользоваться приложением, необходимо ввести токен Тинькофф инвестиций. Его можно взять в настройках, в веб версии")
                        Button("View instruction", action: {
                            print("Instruction open")
                        }).foregroundColor(.blue)
                    }
                    VStack(alignment: .leading) {
                        Group {
                            if let error = viewModel.error {
                                Text(error)
                                    .foregroundColor(.red)
                            } else {
                                Text("Enter token".localized)
                            }
                        }.lineLimit(1)

                        TextField("api token".localized, text: $viewModel.apiToken)
                            .textFieldStyle(PlainTextFieldStyle())
                            .introspectTextField(customize: { textField in
                                textField.becomeFirstResponder()
                            })

                        Divider()
                    }
                    .padding(.top, 50)
                    .padding(.bottom, 50)

                    ActionButton(title: "Check".localized, action: viewModel.actionButton)
                }.padding()
            }
            .accentColor(.appBlack)
            .navigationTitle("Autorization".localized)
            .navigationBarItems(trailing: Toggle("sandbox", isOn: $viewModel.isSandbox))
        }
    }
}
