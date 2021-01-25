//
//  AuthorizationView.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2021.
//

import Foundation
import Introspect
import SwiftUI
import UIKit

class AuthorizationViewModel: EnvironmentCancebleObject, ObservableObject {
    @Published var apiToken: String = ""

    override init(env: Environment = .current) {
        super.init(env: env)

        #if DEBUG
            apiToken = "t.ElO9J6o7HNsTSVH5LG6tRrMqG3bAKQFG3YehULcdPaYzhK0CXcyMVy4rhtbNUuOHwXo8VAs-QUgA-KbHNLg5yg"
        #endif
    }

    override func bindings() {
        super.bindings()
        $apiToken.sink { token in
            Storage.token = token
        }.store(in: &cancellables)
    }
}

struct AuthorizationView: View {
    @ObservedObject var viewModel: AuthorizationViewModel

    var body: some View {
        NavigationView {
            List {
                Text("Что бы пользоваться приложением, необходимо ввести токен Тинькофф инвестиций. Его можно взять в настройках, в веб версии")
                VStack(alignment: .leading) {
                    Text("Enter token")
                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
                    TextField("api token", text: $viewModel.apiToken)
                        .introspectTextField(customize: { textField in
                            textField.becomeFirstResponder()
                        })
                        .padding(EdgeInsets(top: 4, leading: 16, bottom: 8, trailing: 16))
                }
                Button("Done") {}
                    .buttonStyle(DefaultButtonStyle())
            }
            .introspectTableView(customize: { tableView in
                tableView.separatorStyle = .none
                tableView.separatorColor = .clear
            })
            .navigationTitle("Autorization")
        }
    }
}

// struct AuthorizationViewPreview: PreviewProvider {
//    static var previews: some View {
//        AuthorizationView(viewModel: .init())
//    }
// }
