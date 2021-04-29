//
//  AuthorizationView.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2021.
//

import Combine
import Foundation
import Introspect
import SwiftUI

struct AuthorizationView: View {
    @ObservedObject var viewModel: AuthorizationViewModel
    @State var isInstuctionOpen: Bool = false

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
            .sheet(isPresented: $isInstuctionOpen) {
                ViewFactory.instructionView
            }
        }
    }
}
