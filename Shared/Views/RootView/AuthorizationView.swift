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
    let checkToken: (String) -> MoyaError?

    init(checkToken: @escaping (String) -> MoyaError?) {
        self.checkToken = checkToken

        super.init()
    }

//    override func bindings() {
//        super.bindings()
//    }
}

struct AuthorizationView: View {
    @ObservedObject var viewModel: AuthorizationViewModel

    @State var apiToken: String = ""
    @State var error: String?

    init(viewModel: AuthorizationViewModel) {
        self.viewModel = viewModel
        if isMe {
            _apiToken = .init(initialValue: "t.ElO9J6o7HNsTSVH5LG6tRrMqG3bAKQFG3YehULcdPaYzhK0CXcyMVy4rhtbNUuOHwXo8VAs-QUgA-KbHNLg5yg")
        }
    }

    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack {
                    Text("Что бы пользоваться приложением, необходимо ввести токен Тинькофф инвестиций. Его можно взять в настройках, в веб версии")
                    VStack(alignment: .leading) {
                        Text("Enter token \(apiToken)")
                        TextField("api token", text: $apiToken)
                            .textFieldStyle(PlainTextFieldStyle())
                            .introspectTextField(customize: { textField in
                                textField.becomeFirstResponder()
                            })

                        Divider()
                    }
                    .padding(.top, 50)
                    .padding(.bottom, 50)

                    Button(action: {
                        self.error = viewModel.checkToken(apiToken)?.localizedDescription
                    }, label: {
                        Text("Done")
                            .font(.title3)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .multilineTextAlignment(.center)
                            .background(Color.litleGray)
                            .cornerRadius(5)
                    })
                        .buttonStyle(DefaultButtonStyle())
                }.padding()
            }
            .accentColor(.appBlack)
            .navigationTitle("Autorization")
        }
    }
}
